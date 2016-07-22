# == Class: midonet
#
# Install all the midonet modules in a single machine with all
# the default parameters.
#
# == Examples
#
# The only way to call this class is using the include reserved word:
#
#     include midonet
#
# To more advanced usage of the midonet puppet module, check out the
# documentation for the midonet's modules:
#
# - midonet::repository
# - midonet::midonet_agent
# - midonet::midonet_api
# - midonet::midonet_cli
# - midonet::neutron_plugin
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
class midonet {

    include ::midonet::params

    $neutron_auth_creds = {
      'neutron_auth_uri' => 'http://controller:9696',
      'admin_username'        => 'midogod',
      'admin_password'        => 'testmido',
      'admin_tenant_name'     => 'admin',
  }
    # Add midonet-agent
    class { 'midonet::midonet_agent':
      zk_servers => [{
          'ip' => $::ipaddress}
          ],
    }

    # Add midonet-cluster
    class {'midonet::midonet_cluster':
        zookeeper_hosts      => [{
          'ip' => $::ipaddress}
          ]
        cassandra_servers    => ['127.0.0.1'],
        cassandra_rep_factor => '1'.
        keystone_admin_token => 'testmido',
        keystone_host        => '127.0.0.1'
    }

    # Add midonet-cli
    class {'midonet::midonet_cli':}

# TODO(carmela): This workaround has been added in order to be able to handle
# dependencies on the custom providers. Currently there's no official faraday
# package for RHEL-based. We are working on getting it included in EPEL repos.
# Detailed info: https://midonet.atlassian.net/browse/PUP-30

    if ! defined(Package[$::midonet::params::midonet_faraday_package]) {
      if $::osfamily == 'RedHat' {
        package { $::midonet::params::midonet_faraday_package:
          ensure => present,
          source => $::midonet::params::midonet_faraday_url
        } ->
        package { $::midonet::paramsmidonet_multipart_post_package:
          ensure => present,
          source => $::midonet::paramsmidonet_multipart_post_url
        }
      }
      else {
        package { 'ruby-faraday':
          ensure => present,
          before => Midonet_host_registry[$::hostname]
        }
      }
    }


    # Register the host
    midonet_host_registry { $::hostname:
      ensure          => present,
      midonet_api_url => 'http://127.0.0.1:8080',
      username        => 'midogod',
      password        => 'midogod',
      require         => Class['midonet::midonet_agent']
    } ->

    neutron_network { 'ext-net':
      ensure              => present,
      shared              => true,
      router_external     => true,
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_subnet { 'ext-subnet':
      allocation_pools    => ['start=172.17.0.10,end=172.17.0.200'],
      enable_dhcp         => false,
      gateway_ip          => '172.17.0.3',
      cidr                => '172.17.0.0/24',
      network_name        => 'net-edge1-gw1',
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_router { 'edge-router':
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_router_interface { 'edge-router:ext-subnet':
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_network { 'net-edge1-gw1':
      tenant_id             => 'admin',
      provider_network_type => 'uplink',
      neutron_credentials   => $neutron_auth_creds
    } ->

    neutron_subnet { 'subnet-edge1-gw1':
      enable_dhcp         => false,
      cidr                => '172.17.0.0/24',
      tenant_id           => 'admin',
      network_name        => 'net-edge1-gw1',
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_port { 'testport':
      network_name        => 'net-edge-gw1',
      binding_host_id     => $::hostname,
      binding_profile     => {'interface_name' => 'eth1'}
      fixed_ip            => '172.17.0.3',
      neutron_credentials => $neutron_auth_creds
    } ->

    neutron_router_interface { 'edge-router:null':
      port                => 'testport',
      neutron_credentials => $neutron_auth_creds
}



}
