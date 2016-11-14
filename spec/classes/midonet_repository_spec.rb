require 'spec_helper'

describe 'midonet::repository' do
  context 'with default parameters (debian)' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :lsbdistid          => 'Ubuntu',
        :lsbdistrelease     => '16.04',
        :puppetversion      => Puppet.version        
      }
    end
    it { is_expected.to contain_class('midonet::repository::ubuntu').with(
        'is_mem'                => 'false',
        'midonet_version'       => '5.2',
        'midonet_stage'         => 'stable',
        'openstack_release'     => 'mitaka',
        'mem_version'           => '5.2',
        'mem_username'          => nil,
        'mem_password'          => nil
      ) }
  end

  context 'with default parameters (centos)' do
    let :facts do
      {
        :osfamily                     => 'RedHat',
        :operatingsystemmajrelease    => '7'
      }
    end
    it { is_expected.to contain_class('midonet::repository::centos').with(
        'is_mem'                => 'false',
        'midonet_version'       => '5.2',
        'midonet_stage'         => 'stable',
        'openstack_release'     => 'mitaka',
        'mem_version'           => '5.2',
        'mem_username'          => nil,
        'mem_password'          => nil
      ) }
  end

  context 'with custom parameters (debian)' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :lsbdistid          => 'Ubuntu',
        :lsbdistrelease     => '16.04',
        :puppetversion      => Puppet.version
      }
    end
    let :params do
      {
        :is_mem => true,
        :mem_version => '6',
        :mem_username => 'sample_username',
        :mem_password => 'sample_password',
      }
    end
    it { is_expected.to contain_class('midonet::repository::ubuntu').with(
        'is_mem'                => 'true',
        'midonet_version'       => '5.2',
        'midonet_stage'         => 'stable',
        'openstack_release'     => 'mitaka',
        'mem_version'           => '6',
        'mem_username'          => 'sample_username',
        'mem_password'          => 'sample_password'
      ) }
  end

  context 'with custom parameters (centos)' do
    let :facts do
      {
        :osfamily                     => 'RedHat',
        :operatingsystemmajrelease    => '7',
        :puppetversion                => Puppet.version

      }
    end
    let :params do
      {
        :is_mem => true,
        :mem_version => '6',
        :mem_username => 'sample_username',
        :mem_password => 'sample_password',
      }
    end
    it { is_expected.to contain_class('midonet::repository::centos').with(
        'is_mem'                => 'true',
        'midonet_version'       => '5.2',
        'midonet_stage'         => 'stable',
        'openstack_release'     => 'mitaka',
        'mem_version'           => '6',
        'mem_username'          => 'sample_username',
        'mem_password'          => 'sample_password'
      ) }
  end
end
