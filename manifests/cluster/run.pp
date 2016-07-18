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
  $service_name         = 'midonet-cluster',
  $service_ensure     = 'running',
  $service_enable     = true,
  $cluster_config_path  = '/etc/midonet/midonet.conf',
  $zookeeper_hosts   = [{ 'ip' => '127.0.0.1', 'port' => '2181' }],
) {

  file { 'cluster_config':
    ensure  => present,
    path    => $cluster_config_path,
    content => template('midonet/cluster/midonet.conf.erb'),
    require => Package['midonet-cluster'],
  } ~>

  service { 'midonet-cluster':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }
}
