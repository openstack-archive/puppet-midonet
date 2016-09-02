# == Class: midonet::mem::vhost
#
# This class installs apache2/httpd server and configures a custom virtualhost
# for midonet-manager.
#
# === Parameters
#
# [*analytics_ip*]
#  The public IP of where the analytics service is listening.
#
# [*cluster_ip*]
#  The public IP of where
#
# [*is_insights*]
#   Boolean defining if insights is being used or not
#
# [*mem_apache_port*]
#   Port where apache will listen for midonet-manager. Default is '80'
#
# [*mem_apache_docroot*]
#   Document root for mem vhost. Default '/var/www/html'
#
# [*mem_apache_servername*]
#   Servername for the mem vhost
#
# [*mem_api_namespace*]
#   Path where the api endpoint is. Default 'midonet-api'
#
# [*mem_trace_namespace*]
#   Path where the analytics traces endpoint is. Default 'traces'
#
# [*mem_analytics_namespace*]
#   Path where the analyics endpoint is. Default 'analytics'
#
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.

class midonet::mem::vhost (
  $analytics_ip             = $::ipaddress,
  $cluster_ip               = $::ipaddress,
  $is_insights              = false,
  $mem_apache_servername    = $::midonet::params::mem_apache_servername,
  $mem_apache_docroot       = $::midonet::params::mem_apache_docroot,
  $mem_api_namespace        = $::midonet::params::mem_api_namespace,
  $mem_trace_namespace      = $::midonet::params::mem_trace_namespace,
  $mem_analytics_namespace  = $::midonet::params::mem_analytics_namespace,
  $mem_proxy_preserve_host  = $::midonet::params::mem_proxy_preserve_host,
  $mem_apache_port          = $::midonet::params::mem_apache_port,
  $is_ssl                   = undef,
  $ssl_cert                 = undef,
  $ssl_key                  = undef,
) inherits midonet::params {

  $aliases = [
    {
      'alias' => 'midonet-manager',
      'path'  => '/var/www/html/midonet-manager',
    },
  ]

  $headers     = [
    'set    Access-Control-Allow-Origin  *',
    'append Access-Control-Allow-Headers Content-Type',
    'append Access-Control-Allow-Headers X-Auth-Token',
  ]


  if $is_insights {

    $proxy_pass = [
      {
        'path' => "/${mem_api_namespace}",
        'url'  => "http://${cluster_ip}:8181/midonet-api",
      },
      {
        'path' => "/${mem_trace_namespace}",
        'url'  => "wss://${cluster_ip}:8460/trace",
      },
      {
        'path' => "/${mem_analytics_namespace}",
        'url'  => "wss://${analytics_ip}:8080/analytics",
      },
    ]
  }
  else {

    $proxy_pass = [
      {
        'path' => "/${mem_api_namespace}",
        'url'  => "http://${cluster_ip}:8181/midonet-api",
      },
      {
        'path' => "/${mem_trace_namespace}",
        'url'  => "wss://${cluster_ip}:8460/trace",
      },
    ]
  }


  validate_array($proxy_pass)
  validate_string($mem_apache_docroot)

  include ::apache
  include ::apache::mod::headers
  include ::apache::mod::proxy
  include ::apache::mod::proxy_http

  if $is_ssl {
    apache::vhost { 'midonet-mem':
      servername                  => $mem_apache_servername,
      docroot                     => $mem_apache_docroot,
      proxy_preserve_host         => $mem_proxy_preserve_host,
      proxy_pass                  => $proxy_pass,
      headers                     => $headers,
      aliases                     => $aliases,
      ssl                         => true,
      ssl_proxyengine             => true,
      ssl_cert                    => $ssl_cert,
      ssl_key                     => $ssl_key,
      ssl_proxy_verify            => none,
      ssl_proxy_check_peer_cn     => off,
      ssl_proxy_check_peer_name   => off,
      ssl_proxy_check_peer_expire => off,
      require                     => Package[$midonet::params::mem_package],
    }
  }
  else {
    apache::vhost { 'midonet-mem':
      servername          => $mem_apache_servername,
      docroot             => $mem_apache_docroot,
      proxy_preserve_host => $mem_proxy_preserve_host,
      proxy_pass          => $proxy_pass,
      headers             => $headers,
      aliases             => $aliases,
      require             => Package[$midonet::params::mem_package],
    }
  }
}
