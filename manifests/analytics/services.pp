# == Class: midonet::analytics::services
# Check out the midonet::analytics class for a full understanding of
# how to use the midonet::analytics resource
#
# Installs midonet-analytics and midonet-tools package
#
# === Parameters
#
# [*analytics_package_name*]
#   For making mn-conf command available in the Analytics Node
#   Default: midonet-analytics
#
# [*tools_package_name*]
#   For making mn-conf command available in the Analytics Node
#   Default: midonet-tools
#
# [*elk_package_name*]
#   Name of the elk package
#   Default: midonet-elk
#
# [*calliope_port*]
#  Port where calliope listens to
#
# [*midonet_version*]
#  Port where calliope listens to
#
# === Authors
#
# Midonet (http://midonet.org)
#
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

class midonet::analytics::services (
  $analytics_package_name      = 'midonet-analytics',
  $tools_package_name          = 'midonet-tools',
  $elk_package_name            = 'midonet-elk',
  $calliope_port               = '8080',
  $midonet_version             = '5.2'
) {
  include ::stdlib
  $real_analytics_package_name = versioncmp($midonet_version,'5.2') ? {'1' => $elk_package_name, default => $analytics_package_name}

  if $::osfamily == 'Debian' and $::lsbdistrelease == '14.04'
  {
    $logstash_command = 'initctl restart logstash'
  }
  else {
    $logstash_command = 'service logstash restart'
  }

  if versioncmp($midonet_version,'5.2') > 0 {

    if $::osfamily == 'Debian' {
      exec {'update-ca-certificates -f':
        path   => ['/usr/bin', '/usr/sbin','/bin'],
        before => Package[$tools_package_name],
      }
    }
    package { $tools_package_name:
      ensure => present,
      name   => $tools_package_name,
    }

    package { $real_analytics_package_name:
      ensure => present,
      name   => $real_analytics_package_name,
    } ->

    exec { $logstash_command:
      path    => ['/usr/bin', '/usr/sbin','/sbin'],
      require => Package[$real_analytics_package_name],
    }

    exec {'service elasticsearch-es-01 restart':
      path    => ['/usr/bin', '/usr/sbin',],
      require => Package[$real_analytics_package_name],
    }

  }

  else {
    package { $tools_package_name:
      ensure => present,
      name   => $tools_package_name,
    }

    package { $real_analytics_package_name:
      ensure => present,
      name   => $real_analytics_package_name,
    } ->

    exec { $logstash_command:
      path   => ['/usr/bin', '/usr/sbin','/sbin'],
      before => Service[$real_analytics_package_name],
    }

    unless $calliope_port == '8080' {
      exec { "echo calliope.service.ws_port : ${calliope_port} | mn-conf set -t default":
        path   => ['/usr/bin', '/bin'],
        before => Service[$real_analytics_package_name],
      }
    }

    service { $real_analytics_package_name:
      ensure  => 'running',
      name    => $real_analytics_package_name,
      enable  => true,
      require => Package[$real_analytics_package_name],
    }

  }


}
