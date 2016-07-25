# == Class = midonet::params
#
# Configure the parameters for midonet module
#
# === Parameters
#
# [*midonet_repo_baseurl*]
#   Address of the midonet repository

class midonet::params {

  $midonet_repo_baseurl             = 'builds.midonet.org'
  $midonet_key_url                  = "https://${midonet_repo_baseurl}/midorepo.key"

  $midonet_faraday_package          = 'tfm-rubygem-faraday'
  $midonet_faraday_url              = 'http://yum.theforeman.org/nightly/el7/x86_64/tfm-rubygem-faraday-0.9.1-3.el7.noarch.rpm'
  $midonet_multipart_post_package   =  'tfm-rubygem-multipart-post'
  $midonet_multipart_post_url       =  'http://yum.theforeman.org/nightly/el7/x86_64/tfm-rubygem-multipart-post-1.2.0-4.el7.noarch.rpm'

  # midonet MEM Manager
  $mem_package                      = 'midonet-manager'
  $mem_install_path                 = '/var/www/html/midonet-manager'

  # MEM Manager config.js parameters
  $agent_config_api_namespace       = 'conf'
  $analytics_ws_api_url             = "wss://${::ipaddress}:8080/analytics"
  $api_host                         = "http://${::ipaddress}:8181"
  $api_namespace                    = 'midonet-api'
  $api_token                  	    = false
  $api_version                      = '5.0'
  $login_host                       = "http://${::ipaddress}:8181"
  $poll_enabled                     = true
  $login_animation_enabled          = true
  $trace_api_host                   = "http://${::ipaddress}:8181"
  $traces_ws_url                    = "wss://${::ipaddress}:8460"

  # MEM vhost parameters for apache conf
  $apache_port                      = '80'
  $servername                       = "http://$::ipaddress"
  $docroot                          = '/var/www/html'


}
