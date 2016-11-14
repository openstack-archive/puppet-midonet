require 'spec_helper'

describe 'midonet::cli' do

  let :pre_condition do
    "include ::midonet::repository"
  end

  let :default_params do
    {
    :api_endpoint => 'http://87.23.43.2:8080/midonet-api',
    :username     => 'midonet',
    :password     => 'dummy',
    :tenant_name  => 'midonet'
    }
  end

  shared_examples_for 'set up midonet cli' do
    context 'with default params' do
      let :params do
        default_params
      end

     it { is_expected.to contain_package(
       'python-midonetclient').with(
         'ensure'           => 'present'
       )
      }
    it {
      is_expected.to contain_midonet_client_conf('cli/api_url').with_value(params[:api_endpoint])
      is_expected.to contain_midonet_client_conf('cli/username').with_value(params[:username])
      is_expected.to contain_midonet_client_conf('cli/password').with_value(params[:password])
      is_expected.to contain_midonet_client_conf('cli/project_id').with_value(params[:tenant_name])
     }
   end

  end


  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '14.04',
        :lsbdistrelease            => '14.04',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '14',
        :puppetversion             => '3.8.7',
        :lsbdistid                 => 'ubuntu',
        :lsbdistcodename           => 'Trusty'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up midonet cli'
  end

  context 'on Ubuntu 16.04' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '16.04',
        :lsbdistrelease            => '16.04',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '16',
        :puppetversion             => '3.8.7',
        :lsbdistid                 => 'ubuntu',
        :lsbdistcodename           => 'Xenial'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up midonet cli'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemrelease    => '7',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '7',
        :puppetversion             => '3.8.7',
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up midonet cli'
    it { is_expected.to contain_package('epel-release').with_ensure('installed') }
  end
end
