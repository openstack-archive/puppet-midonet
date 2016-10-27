# == Class: midonet::analytics
#
# Installs midonet analytics packages
#
# === Parameters
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
# [*zookeeper_hosts*]
#   List of IPs and ports of hosts where Zookeeper is installed
#
# Please note that Keystone port is not mandatory and defaulted to 35537.
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

class midonet::analytics (
  $zookeeper_hosts,
  $is_mem             = true,
  $manage_repo        = false,
  $mem_username       = undef,
  $mem_password       = undef,
  $heap_size_gb       = '4',
  $allinone           = false,
  $curator_version    = '3.5',
  $calliope_port      = undef,
) {


    class { 'logstash':
      manage_repo  => true,
      java_install => true,
      repo_version => '1.5',
    }
    contain ::logstash

    class { 'elasticsearch':
      manage_repo  => true,
      repo_version => '1.7',
      require      => Class['::logstash']
    }
    contain ::elasticsearch

    elasticsearch::instance { 'es-01':
      require => Class['::logstash','::elasticsearch']
    }

    class { 'curator':
      version => $curator_version,
    }
    contain ::curator

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
            before            => Class['midonet::analytics::services',
            'midonet::analytics::quickstart']
          }
        }
      }

      class { 'midonet::analytics::services':
        calliope_port => $calliope_port,
        require       => [Class['::logstash','::elasticsearch','::curator'],
        Elasticsearch::Instance['es-01']]
      }

      unless $allinone {
        class { 'midonet::analytics::quickstart':
          zookeeper_hosts => $zookeeper_hosts,
          notify          => Service['midonet-analytics']
        }
      }



    }
    else  {
      notice('Skipping installation of midonet analytics services')
    }

    if $::osfamily == 'Debian' {
      file_line { 'Set LS_HEAP_SIZE':
        path    => '/etc/default/logstash',
        line    => "LS_HEAP_SIZE='${heap_size_gb}g'",
        match   => '^LS_HEAP_SIZE.*$',
        require => Package['logstash'],
        notify  => Service['logstash'],
      }

      file_line { 'Set ES_HEAP_SIZE':
        path    => '/etc/default/elasticsearch',
        line    => "ES_HEAP_SIZE='${heap_size_gb}g'",
        match   => '^ES_HEAP_SIZE.*$',
        require => Package['elasticsearch'],
        notify  => Service['elasticsearch-instance-es-01'],
      }
    }
    if $::osfamily == 'RedHat' {
      file_line { 'Set LS_HEAP_SIZE':
        path    => '/etc/sysconfig/logstash',
        line    => "LS_HEAP_SIZE='${heap_size_gb}g'",
        match   => '^LS_HEAP_SIZE.*$',
        require => Package['logstash'],
        notify  => Service['logstash'],
      }

      file_line { 'Set ES_HEAP_SIZE':
        path    => '/etc/sysconfig/elasticsearch',
        line    => "ES_HEAP_SIZE='${heap_size_gb}g'",
        match   => '^ES_HEAP_SIZE.*$',
        require => Package['elasticsearch'],
        notify  => Service['elasticsearch-instance-es-01'],
      }
    }
}
