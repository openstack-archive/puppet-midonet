# == Class: midonet::analytics::quickstart
# Check out the midonet::analytics class for a full understanding of
# how to use the midonet::analytics resource
#
# Configures analytics box for NSDB node access
#
# Parameters
# [*config_path*]
# Path for storing the zookeeper configuration file.
# Default: /etc/midonet/midonet.conf
#
# [*zookeeper_hosts*]
#   List of IPs and ports of hosts where Zookeeper is installed
#
# [*cassandra_servers*]
#   List of IPs and ports of where cassandra is installed
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


class midonet::analytics::quickstart (
  $config_path      = '/etc/midonet/midonet.conf',
  $zookeeper_hosts,
  $cassandra_servers,
) {

  file { '/tmp/nsdb_config.sh':
    ensure  => present,
    content => template('midonet/analytics/nsdb_config.sh.erb'),
  } ->

  exec { '/bin/bash /tmp/nsdb_config.sh': }

  file { 'set_config':
    ensure  => present,
    path    => $config_path,
    content => template('midonet/analytics/midonet.conf.erb'),
    before  => File['/tmp/nsdb_config.sh'],
  }

  file { 'analytics_settings':
    ensure  => present,
    path    => '/tmp/analytics_settings.conf',
    content => template('midonet/analytics/analytics_settings.erb'),
    before  => File['/tmp/nsdb_config.sh'],
  }
}
