# == Class: midonet::agent
#
# Install and run midonet_agent
#
# === Parameters
#
# [*package_name*]
#   Name of the package in the repository. Default: undef
#
# [*service_name*]
#   Name of the MN agent service. Default: undef
#
# [*agent_config_path*]
#   Full path to the MN agent config. Default: undef
#
# [*package_ensure*]
#   Whether the package should be installed or not. Default: undef
#
# [*manage_java*]
#   Set to true to install java. Defaults: undef
#
# [*zookeeper_hosts*]
#   List of hash [{ip, port}] Zookeeper instances that run in cluster.
#     Default: undef
#
# === Examples
#
# The easiest way to run the class is:
#
#     include midonet::agent
#
# This call assumes that there is a zookeeper instance and a cassandra instance
# running in the target machine, and will configure the midonet-agent to
# connect to them.
#
# This is a quite naive deployment, just for demo purposes. A more realistic one
# would be:
#
#    class {'midonet::agent':
#            zookeeper_hosts =>  [{'ip'   => 'host1',
#                                  'port' => '2183'},
#                                 {'ip'   => 'host2'}],
#          }
#
# Please note that Zookeeper port is not mandatory and defaulted to 2181
#
# You can alternatively use the Hiera.yaml style:
#
# midonet::agent::zookeeper_hosts:
#     - ip: 'host1'
#       port: 2183
#     - ip: 'host2'
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

class midonet::agent (
  $package_name       = undef,
  $service_name       = undef,
  $service_ensure     = undef,
  $service_enable     = undef,
  $agent_config_path  = undef,
  $package_ensure     = undef,
  $manage_java        = undef,
  $zookeeper_hosts    = undef,
) {

  include midonet::repository

  class { 'midonet::agent::install':
    package_name   => $package_name,
    package_ensure => $package_ensure,
    manage_java    => $manage_java,
    require        => Class['midonet::repository'],
  }

  class { 'midonet::agent::run':
    service_name      => $service_name,
    service_ensure    => undef,
    service_enable    => undef,
    agent_config_path => $agent_config_path,
    zookeeper_hosts   => $zookeeper_hosts,
    require           => Class['midonet::agent::install'],
  }
}
