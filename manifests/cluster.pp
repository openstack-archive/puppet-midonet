# == Class: midonet::midonet_cluster
#
# Install and run midonet_cluster
#
# === Parameters
#
# [*package_name*]
#   List of hash [{ip, port}] Zookeeper instances that run in cluster.
# [*service_name*]
#   Whether to authenticate the cluster request through a Keystone service. Default:
#   false.
# [*service_ensure*]
#   Whether to enable the vtep service endpoint. Default: false
# [*service_enable*]
#   The name of the tomcat package to install. The module already inserts a
#   value depending on the distribution used. Don't override it unless you know
#   what you are doing.
# [*cluster_config_path*]
#   Let choose the address to bind instead of all of them
# [*zookeeper_hosts*]
#   Exposed IP address. By default, it exposes the first internet address that
#   founds in the host.
# [*cassandra_servers*]
#   TCP listening port. By default, 8080
# [*cassandra_rep_factor*]
#   Keystone service endpoint IP. Not used if keystone_auth is false.
# [*keystone_admin_token*]
#   Keystone service endpoint port. Not used if keystone_auth is false.
# [*keystone_host*]
#   Keystone host
# [*keystone_port*]
#   Keystone port
#
# === Examples
#
# This would be a deployment for demo purposes
# would be:
#
#    class {'midonet::midonet_cluster':
#        zookeeper_hosts        => [{
#          'ip' => $::ipaddress}
#          ]
#        cassandra_servers      => ['127.0.0.1'],
#        cassandra_rep_factor   => 1.
#        keystone_admin_token   => 'fake_token',
#        keystone_host          => '127.0.0.1'
#    }
#

#
# Please note that Zookeeper port is not mandatory and defaulted to 2181.
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
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
class midonet::cluster (
  $package_name           = undef,
  $service_name           = undef,
  $service_ensure         = undef,
  $service_enable         = undef,
  $cluster_config_path    = undef,
  $keystone_port          = undef,
  $zookeeper_hosts,
  $cassandra_servers,
  $cassandra_rep_factor,
  $keystone_admin_token,
  $keystone_host,
) {

    class { 'midonet::cluster::install':
      package_name => $package_name,
    } ->

    class { 'midonet::cluster::run':
      service_name         => $service_name,
      service_ensure       => $service_ensure,
      service_enable       => $service_enable,
      cluster_config_path  => $cluster_config_path,
      zookeeper_hosts      => $zookeeper_hosts,
      cassandra_servers    => $cassandra_servers,
      cassandra_rep_factor => $cassandra_rep_factor,
      keystone_admin_token => $keystone_admin_token,
      keystone_host        => $keystone_host,
      keystone_port        => $keystone_port
    }
}
