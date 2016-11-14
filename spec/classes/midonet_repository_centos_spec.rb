require 'spec_helper'

describe 'midonet::repository::centos' do
  context 'with default parameters (centos)' do
    let :facts do
      {
        :osfamily                     => 'RedHat',
        :operatingsystemmajrelease    => '7',
        :puppetversion                => Puppet.version
      }
    end
    let :params do
      {
        :is_mem => false,
        :midonet_version => '5.2',
        :midonet_stage => 'stable',
        :openstack_release => 'mitaka',
        :mem_version => '5',
        :mem_username => nil,
        :mem_password => nil,
      }
    end

    it { is_expected.to contain_class('midonet::params') }

    it { is_expected.to contain_yumrepo('midonet').with(
        'name' => 'midonet',
        'baseurl' => 'http://builds.midonet.org/midonet-5.2/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
    it { is_expected.to contain_yumrepo('midonet-openstack-integration').with(
        'name' => 'midonet-openstack-integration',
        'baseurl' => 'http://builds.midonet.org/openstack-mitaka/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
    it { is_expected.to contain_yumrepo('midonet-misc').with(
        'name' => 'midonet-misc',
        'baseurl' => 'http://builds.midonet.org/misc/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
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
        :midonet_version => '5.2',
        :midonet_stage => 'stable',
        :openstack_release => 'mitaka',
        :mem_version => '6',
        :mem_username => 'sample_username',
        :mem_password => 'sample_password',
      }
    end

    it { is_expected.to contain_class('midonet::params') }

    it { is_expected.to contain_yumrepo('midonet').with(
        'name' => 'mem',
        'baseurl' => 'http://sample_username:sample_password@builds.midonet.org/mem-6/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
    it { is_expected.to contain_yumrepo('midonet-openstack-integration').with(
        'name' => 'mem-openstack-integration',
        'baseurl' => 'http://builds.midonet.org/openstack-mitaka/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
    it { is_expected.to contain_yumrepo('midonet-misc').with(
        'name' => 'mem-misc',
        'baseurl' => 'http://builds.midonet.org/misc/stable/el7',
        'enabled' => '1',
        'gpgcheck' => '1',
        'gpgkey' => 'https://builds.midonet.org/midorepo.key',
        'timeout' => '60'
      )
    }
  end
end
