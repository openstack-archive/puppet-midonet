# == Class: midonet::gateway::static
#
# Set up a fake uplink with static routing on a gateway node
#
# === Parameters
#
# [*network_id*]
#   (Mandatory) Name of the bridge that will be created through midonet-cli
#
# [*cidr*]
#   (Mandatory) Network that will be assigned to the fake uplink
#
# [*gateway_ip*]
#   (Mandatory) Gateway IP through which the packets will go
#
# [*service_host*]
#   (Mandatory) Host where the Midonet API runs
#
# [*service_dir*]
#   (Mandatory) Folder on which to place the pidfile and some other temporary
#   files for the well functioning of this script (ex: /tmp/status)
#
# [*zookeeper_hosts*]
#   (Mandatory) Comma-separated list of zookeeper hosts. These are a hash consisting of two
#   fields, 'ip' and 'port'. Example: [ { 'ip' => '12.153.140.2', 'port' => '2181'}]
#
# [*api_port*]
#   (Mandatory) Port that the Midonet API binds
#
# [*scripts_dir*]
#   (Optional) Path where to place the necessary scripts
#
# [*ensure_scripts*]
#   (Optional) Status of the scripts
#
# [*mido_db_user*]
#   (Optional) Username to authenticate against the DB
#
# [*mido_db_password*]
#   (Optional) Password to authenticate against the DB
#
# === Examples
#
# The easiest way to run the class is:
#
#      class { 'midonet::gateway::static':
#        network_id => 'example_netid',
#        cidr => '200.0.0.1/24',
#        gateway_ip => '200.0.0.1',
#        service_host => '127.0.0.1',
#        service_dir => '/tmp/status',
#        zookeeper_hosts => [
#          {
#            'ip'=>'127.0.0.1',
#            'port'=>'2181'
#          }
#        ],
#        api_port => '8181'
#      }
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class midonet::gateway::static (
  $network_id,
  $cidr,
  $gateway_ip,
  $service_host,
  $service_dir,
  $zookeeper_hosts,
  $api_port,
  $scripts_dir       = '/tmp',
  $uplink_script     = 'create_fake_uplink_l2.sh',
  $midorc_script     = 'midorc',
  $functions_script  = 'functions',
  $ensure_scripts    = 'present',
  $mido_db_user      = 'admin',
  $mido_db_password  = 'admin',
) {

  # Install screen, as it's needed by the script
  package { 'screen': ensure => installed }

  # Place script and helper files before executing it
  file { 'fake_uplink_script':
    ensure  => $ensure_scripts,
    path    => "${scripts_dir}/create_fake_uplink_l2.sh",
    content => template('midonet/gateway/create_fake_uplink_l2.sh.erb'),
  }
  file { 'midorc':
    ensure  => $ensure_scripts,
    path    => "${scripts_dir}/midorc",
    content => template('midonet/gateway/midorc.erb'),
  }
  file { 'functions':
    ensure  => $ensure_scripts,
    path    => "${scripts_dir}/functions",
    source  => 'puppet:///modules/midonet/gateway/functions',
    require => Package['screen'],
  }

  # Finally, execute the script
  exec { "/bin/bash ${scripts_dir}/create_fake_uplink_l2.sh":
    require => [
      File['fake_uplink_script', 'midorc', 'functions'],
      Package['python-midonetclient'],
    ]
  }
}
