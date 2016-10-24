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
# [*midonet-tools*]
#   For making mn-conf command available in the Analytics Node
#   Default: midonet-tools
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

class midonet::analytics::services (
  $analytics_package_name      = 'midonet-analytics',
  $tools_package_name          = 'midonet-tools',
) {

  package { $tools_package_name:
    ensure => present,
    name   => $tools_package_name,
  }

  package { $analytics_package_name:
    ensure => present,
    name   => $analytics_package_name,
  } ->

  exec {'service logstash restart':
    path        => ['/usr/bin', '/usr/sbin',],
  } ->

  service { $analytics_package_name:
    ensure  => 'running',
    name    => $analytics_package_name,
    enable  => true,
    require => Package[$analytics_package_name],
  }


}
