# == Class: midonet::mem::params
#
# Specify values for parameters and variables for different platform
#

class midonet::mem::params {
  # midonet mem_manager
  $mem_package             = 'midonet-manager'
  $mem_install_path           = '/var/www/html/midonet-manager'

  # MEM config.js parameters
  $agent_config_api_namespace = 'conf'
  $analytics_ws_api_url       = "wss://${::ipaddress}:8080/analytics"
  $api_host                   = "http://${::ipaddress}:8181"
  $api_namespace              = 'midonet-api'
  $api_token                  = false
  $api_version                = '5.0'
  $login_host                 = "http://${::ipaddress}:8181"
  $poll_enabled               = true
  $login_animation_enabled    = true
  $trace_api_host             = "http://${::ipaddress}:8181"
  $traces_ws_url              = "wss://${::ipaddress}:8460"

  # mem::vhost
  $apache_port = '80'
  $servername  = "http://$::ipaddress"
  $docroot     = '/var/www/html'
}

