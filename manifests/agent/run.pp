# == Class: midonet::agent::run
# Check out the midonet::agent class for a full understanding of
# how to use the agent resource
#
# === Parameters
#
#
# [*service_name*]
#   Name of the MN agent service. Default: midolman
#
# [*agent_config_path*]
#   Full path to the MN agent config. Default: /etc/midolman/midolman.conf
#
# [*zookeeper_hosts*]
#   List of hash [{ip, port}] Zookeeper instances that run in cluster.
#     Default: [ { 'ip' => '127.0.0.1', 'port' => '2181' } ]
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

class midonet::agent::run (
  $service_name       = 'midolman',
  $service_ensure     = 'running',
  $service_enable     = true,
  $agent_config_path  = '/etc/midolman/midolman.conf',
  $jvm_config_path    = '/etc/midolman/midolman-env.sh',
  $max_heap_size      = '4096M',
  $zookeeper_hosts,
  $controller_host,
  $metadata_port,
  $shared_secret,
) {

  file { '/tmp/mn-agent_config.sh':
    ensure  => present,
    content => template('midonet/agent/mn-agent_config.sh.erb'),
  } ->

  exec { '/bin/bash /tmp/mn-agent_config.sh': }

  file { 'agent_config':
    ensure  => present,
    path    => $agent_config_path,
    content => template('midonet/agent/midolman.conf.erb'),
    require => Package['midolman'],
    notify  => Service['midolman'],
    before  => File['/tmp/mn-agent_config.sh'],
  }

  file { 'jvm_config':
    ensure  => present,
    path    => $jvm_config_path,
    content => template('midonet/agent/midolman-env.sh.erb'),
    require => Package['midolman'],
    notify  => Service['midolman'],
  }

  service { 'midolman':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }
}
