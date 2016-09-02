# == Class = midonet::params
#
# Configure the parameters for midonet module
#
# === Parameters
#
# [*midonet_repo_baseurl*]
#   Address of the midonet repository

class midonet::params {

  $midonet_repo_baseurl                 = 'builds.midonet.org'
  $midonet_key_url                      = "https://${midonet_repo_baseurl}/midorepo.key"

  $midonet_faraday_package              = 'tfm-rubygem-faraday'
  $midonet_multipart_post_package       = 'tfm-rubygem-multipart-post'
  $foreman_releases_repo_url            = 'http://yum.theforeman.org/releases/latest/el7/$basearch'
  $foreman_releases_repo_gpgkey         = 'https://yum.theforeman.org/releases/latest/RPM-GPG-KEY-foreman'

  # midonet MEM Manager
  $mem_package                          = 'midonet-manager'
  $mem_install_path                     = '/var/www/html/midonet-manager'


  # MEM Manager config.js parameters
  $mem_agent_config_api_namespace       = 'conf'
  $mem_api_token                        = false
  $mem_api_version                      = '5.0'
  $mem_poll_enabled                     = true
  $mem_login_animation_enabled          = true
  $mem_config_file                      = "${mem_install_path}/config/client.js"

  $mem_api_namespace                    = 'midonet-api'
  $mem_trace_namespace                  = 'trace'
  $mem_analytics_namespace              = 'analytics'
  $mem_proxy_preserve_host              = true


  # MEM vhost parameters for apache conf
  $mem_apache_port                      = '80'
  $mem_apache_servername                = $::ipaddress
  $mem_apache_docroot                   = '/var/www/html'


  # OS configuration
  $gem_bin_path                         = '/usr/bin/gem'
}
