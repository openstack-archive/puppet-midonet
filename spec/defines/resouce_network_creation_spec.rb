
#
# Unit tests for midonet_openstack::resources::network_creation
#

require 'spec_helper'

describe 'midonet_openstack::resources::network_creation' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    {
      :api_endpoint            => 'http://127.0.0.1:8181/midonet-api',
      :keystone_username       => 'testingadmin',
      :keystone_password       => 'securepassword',
      :tenant_name             => 'admin',
      :controller_ip           => '127.0.0.1',
      :controller_neutron_port => '9696',
      :network_external        => 'ext-net',
      :allocation_pools        => ['start=172.17.0.10,end=172.17.0.200'],
      :gateway_ip              => '172.17.0.3',
      :subnet_cidr             => '172.17.0.0/24',
      :subnet_name             => 'ext-subnet',
      :edge_router_name        => 'edge-router',
      :edge_network_name       => 'net-edge1-gw1',
      :edge_subnet_name        => 'subnet-edge1-gw1',
      :edge_cidr               => '172.17.0.0/24',
      :port_name               => 'testport',
      :port_fixed_ip           => '172.17.0.3',
      :port_interface_name     => 'eth1'
    }

  end
  end

  shared_examples_for 'configure networks' do

    context 'with default params' do
      let :params do
        default_params
      end

      let :auth_credentials do
        {
          :neutron_auth_uri => "http://127.0.0.1:9696",
          :admin_username        => :params['keystone_username'],
          :admin_password        => :params['keystone_password'],
          :admin_tenant_name     => :params['tenant_name'],
        }

    it 'should configure networks' do
      is_expected.to contain_neutron_network(:params['network_external']).with(
          'external'            => true,
          'shared'              => true,
          'neutron_credentials' => :auth_credentials
      )
      is_expected.to contain_neutron_subnet(:params['subnet_name']).with(
          'allocation_pools'    => :params['allocation_pools'],
          'enable_dhcp'         => false,
          'gateway_ip'          => :params['gateway_ip'],
          'network_name'        => :params['network_external'],
          'cidr'                => :params['subnet_cidr'],
          'neutron_credentials' => :auth_credentials,
      )
      is_expected.to contain_neutron_router(:params['edge_router_name']).with(
          'neutron_credentials' => :auth_credentials,
      )
      is_expected.to contain_neutron_router_interface("edge-router:ext-subnet").with(
          'neutron_credentials' => :auth_credentials,
      )
      is_expected.to contain_neutron_network(:params['edge_network_name']).with(
          'tenant_name'           => :params['tenant_name'],
          'provider_network_type' => 'uplink',
          'neutron_credentials'   => :auth_credentials
      )
      is_expected.to contain_neutron_subnet(:params['edge_subnet_name']).with(
          'allocation_pools'    => :params['allocation_pools'],
          'cidr'                => :params['edge_cidr'],
          'tenant_id'           => :params['tenant_name'],
          'network_name'        => :params['edge_network_name'],
          'neutron_credentials' => :auth_credentials,
      )
      is_expected.to contain_neutron_port(:params['port_name']).with(
          'network_name'        => :params['edge_network_name'],
          'binding_host_id'     => 'tests.midokura.com',
          'fixed_ip'            => :params['port_fixed_ip'],
          'neutron_credentials' => :auth_credentials,
      )
      is_expected.to contain_neutron_router_interface("edge-router:null").with(
          'port'                => :params['port_name'],
          'neutron_credentials' => :auth_credentials,
      )
      end

    end
end

  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :operatingsystemrelease => '14.04',
        :memorysize             => '2048',
        :hostname               => 'tests.midokura.com'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'configure networks'
  end

  context 'on Ubuntu 16.04' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :operatingsystemrelease => '16.04',
        :memorysize             => '2048',
        :hostname               => 'tests.midokura.com'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'configure networks'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :memorysize             => '2048',
        :hostname               => 'tests.midokura.com'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'configure networks'
  end
end
