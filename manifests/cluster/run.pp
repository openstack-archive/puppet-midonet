# == Class: midonet::cluster::run
# Check out the midonet::cluster class for a full understanding of
# how to use the cluster resource
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
class midonet::cluster::run (
  $zookeeper_hosts,
  $cassandra_servers,
  $cassandra_rep_factor,
  $keystone_admin_token,
  $keystone_host,
  $keystone_protocol               = 'http',
  $keystone_port                   = '35357',
  $keystone_tenant_name            = 'admin',
  $service_name                    = 'midonet-cluster',
  $service_ensure                  = 'running',
  $service_enable                  = true,
  $cluster_config_path             = '/etc/midonet/midonet.conf',
  $cluster_jvm_config_path         = '/etc/midonet-cluster/midonet-cluster-env.sh',
  $cluster_host                    = '0.0.0.0',
  $cluster_port                    = '8181',
  $max_heap_size                   = '1024M',
  $heap_newsize                    = '512M',
  $is_insights                     = false,
  $clio_service_udp_port           = undef,
  $clio_target_udp_port            = undef,
  $jmxscraper_target_udp_endpoint  = undef,
  $flow_tracing_service_ws_port    = undef,
  $agent_flow_history_udp_endpoint = undef,
  $calliope_service_ws_port        = undef,
  $insights_ssl                    = undef,
  $analytics_ip                    = undef,
) {

  file { '/tmp/mn-cluster_config.sh':
    ensure  => present,
    content => template('midonet/cluster/mn-cluster_config.sh.erb'),
  } ->

  exec { '/bin/bash /tmp/mn-cluster_config.sh': }

  file { 'cluster_config':
    ensure  => present,
    path    => $cluster_config_path,
    content => template('midonet/cluster/midonet.conf.erb'),
    require => Package['midonet-cluster'],
    notify  => Service['midonet-cluster'],
    before  => File['/tmp/mn-cluster_config.sh'],
  }

  file { 'cluster_jvm_config':
    ensure  => present,
    path    => $cluster_jvm_config_path,
    content => template('midonet/cluster/midonet-cluster-env.sh.erb'),
    require => Package['midonet-cluster'],
    notify  => Service['midonet-cluster'],
  }

  if $is_insights {
    file { 'analytics_settings':
      ensure  => present,
      path    => '/tmp/analytics_settings.conf',
      content => template('midonet/analytics/analytics_settings.erb'),
    } ->
    file { 'analytics_settings_script':
      ensure  => present,
      path    => '/tmp/analytics_settings.sh',
      content => template('midonet/analytics/analytics_settings.sh.erb'),
    } ->
    exec { '/bin/bash /tmp/analytics_settings.sh': }
  }

  service { 'midonet-cluster':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }

  file { '/etc/midonet/subscriptions':
    ensure  => directory,
    source  => 'puppet:///modules/midonet/subscriptions',
    require => Service['midonet-cluster'],
    recurse => true,
  }
}
