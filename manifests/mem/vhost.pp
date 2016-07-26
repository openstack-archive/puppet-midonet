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
  $mem_apache_port        = $midonet::params::mem_apache_port,
  $mem_apache_docroot     = $midonet::params::mem_apache_docroot,
  $mem_apache_servername  = $midonet::params::mem_apache_servername,
  $proxy_pass = [
    { 'path' => "/${midonet::params::mem_api_namespace}",
      'url'  => $midonet::params::mem_api_host,
    },
  ],
  $directories = [
    { 'path'  => $docroot,
      'allow' => 'from all',
    },
  ],
) inherits midonet::params {

  validate_string($mem_apache_port)
  validate_string($mem_apache_docroot)
  validate_string($mem_apache_servername)
  validate_array($proxy_pass)
  validate_array($directories)

  include ::apache
  include ::apache::mod::headers

  apache::vhost { 'midonet-mem':
    port        => $mem_apache_port,
    servername  => $mem_apache_servername,
    docroot     => $mem_apache_docroot,
    proxy_pass  => $proxy_pass,
    directories => $directories,
    require     => Package[$midonet::params::mem_package],
  }
}

