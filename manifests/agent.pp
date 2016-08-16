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
# [*service_ensure*]
#   Whether the service should be running or not. Default: undef
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
# [*is_mem*]
#   Boolean variable - If true puppet will install MEM specific services
#     Default: false
#
# [*manage_repo*]
#   Boolean variable - If true puppet will install repositories on given node
#     Default: false
#
# [*mem_username*]
#   Username which will have access to Midokura repositories
#     Default: undef
#
# [*mem_password*]
#   Password for User which will be used to access the Midokura repositories
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
  $max_heap_size      = undef,
  $zookeeper_hosts,
  $controller_host,
  $metadata_port,
  $shared_secret,
  $is_mem             = false,
  $manage_repo        = false,
  $mem_username       = undef,
  $mem_password       = undef
) {

  include midonet::repository

  class { 'midonet::agent::install':
    package_name   => $package_name,
    package_ensure => $package_ensure,
    manage_java    => $manage_java,
    require        => Class['midonet::repository'],
  }
  contain 'midonet::agent::install'

  class { 'midonet::agent::run':
    service_name      => $service_name,
    service_ensure    => undef,
    service_enable    => undef,
    agent_config_path => $agent_config_path,
    zookeeper_hosts   => $zookeeper_hosts,
    controller_host   => $controller_host,
    metadata_port     => $metadata_port,
    shared_secret     => $shared_secret,
    max_heap_size     => $max_heap_size,
    require           => Class['midonet::agent::install'],
  }
  contain 'midonet::agent::run'

  if $is_mem {
    if $manage_repo == true {
      if !defined(Class['midonet::repository']) {
        class {'midonet::repository':
          is_mem            => $is_mem,
          midonet_version   => undef,
          midonet_stage     => undef,
          openstack_release => undef,
          mem_version       => undef,
          mem_username      => $mem_username,
          mem_password      => $mem_password,
        }
        contain 'midonet::repository'
      }
    }
    class { 'midonet::agent::scrapper':
      require   => Class['midonet::repository'],
    }
    contain 'midonet::agent::scrapper'
  }
  else  {
    notice('Skipping installation of jmx-scrapper')
  }

}
