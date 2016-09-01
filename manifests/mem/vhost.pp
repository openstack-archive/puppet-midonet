# == Class: midonet::mem::vhost
#
# This class installs apache2/httpd server and configures a custom virtualhost
# for midonet-manager.
#
# === Parameters
#
# [*apache_port*]
#  The TCP port where apache2/httpd server is listening on.
#  Note: this value has been defaulted to '80'
#
# [*docroot*]
#   The value for the virtualhost DocumentRoot directive.
#   Note: this value has been defaulted to '/var/www/html'
#
# [*servername*]
#   The value for the virtualhost ServerName directive.
#   Note: this value has been defaulted to "http://$::ipaddress"
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.

class midonet::mem::vhost (
  $analytics_ip  = $::ipaddress,
  $cluster_ip    = $::ipaddress,
  $is_insights   = false,
) inherits midonet::params {

  $aliases = [
    {
      'alias' => 'midonet-manager',
      'path'  => '/var/www/html/midonet-manager',
    },
  ]


  $mem_apache_docroot     = $midonet::params::mem_apache_docroot

  if $is_insights {

    $proxy_pass = [
      {
        'path' => "/${midonet::params::mem_api_namespace}",
        'url'  => "http://${cluster_ip}:8181/midonet-api",
      },
      {
        'path' => "/${midonet::params::mem_trace_namespace}",
        'url'  => "wss://${cluster_ip}:8460/trace",
      },
      {
        'path' => "/${midonet::params::mem_analytics_namespace}",
        'url'  => "wss://${analytics_ip}:8080/analytics",
      },
    ]
  }
  else {

    $proxy_pass = [
      {
        'path' => "/${midonet::params::mem_api_namespace}",
        'url'  => "http://${cluster_ip}:8181/midonet-api",
      },
      {
        'path' => "/${midonet::params::mem_trace_namespace}",
        'url'  => "wss://${cluster_ip}:8460/trace",
      },
    ]
  }

  validate_array($proxy_pass)
  validate_string($mem_apache_docroot)

  include ::apache
  include ::apache::mod::headers

  apache::vhost { 'midonet-mem':
    docroot             => $mem_apache_docroot,
    proxy_preserve_host => 'on',
    proxy_pass          => $proxy_pass,
    headers             => [
    'set    Access-Control-Allow-Origin  *',
    'append Access-Control-Allow-Headers Content-Type',
    'append Access-Control-Allow-Headers X-Auth-Token',
    ],
    aliases             => $aliases,
    require             => Package[$midonet::params::mem_package],
  }
}

