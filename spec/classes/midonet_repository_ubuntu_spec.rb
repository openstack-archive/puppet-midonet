require 'spec_helper'

describe 'midonet::repository::ubuntu' do
  context 'with default parameters (debian)' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :lsbdistid          => 'Ubuntu',
        :lsbdistrelease     => '16.04',
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
    it { is_expected.to contain_class('apt') }
    it { is_expected.to contain_class('apt::update') }
    it { is_expected.to contain_apt__key('midorepo') }

    it { is_expected.to contain_apt__source('midonet').with(
        'location' => 'http://builds.midonet.org/midonet-5.2',
        'release' => 'stable',
        'key' => '{"id"=>"E9996503AEB005066261D3F38DDA494E99143E75", "server"=>"subkeys.pgp.net"}',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_apt__source('midonet-openstack-integration').with(
        'location' => 'http://builds.midonet.org/openstack-mitaka',
        'release' => 'stable',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_apt__source('midonet-openstack-misc').with(
        'location' => 'http://builds.midonet.org/misc',
        'release' => 'stable',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_exec('update-midonet-repos').with(
        'command' => '/bin/true',
        'require' => '[Exec[apt_update]{:command=>"apt_update"}, Apt::Source[midonet]{:name=>"midonet"}, Apt::Source[midonet-openstack-integration]{:name=>"midonet-openstack-integration"}]'
      )
    }
  end

  context 'with custom parameters (debian)' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :lsbdistid          => 'Ubuntu',
        :lsbdistrelease     => '16.04',
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
    it { is_expected.to contain_class('apt') }
    it { is_expected.to contain_class('apt::update') }
    it { is_expected.to contain_apt__key('midorepo') }

    it { is_expected.to contain_apt__source('midonet').with(
        'location' => 'http://sample_username:sample_password@builds.midonet.org/mem-6',
        'release' => 'stable',
        'key' => '{"id"=>"E9996503AEB005066261D3F38DDA494E99143E75", "server"=>"subkeys.pgp.net"}',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_apt__source('midonet-openstack-integration').with(
        'location' => 'http://builds.midonet.org/openstack-mitaka',
        'release' => 'stable',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_apt__source('midonet-openstack-misc').with(
        'location' => 'http://builds.midonet.org/misc',
        'release' => 'stable',
        'include' => '{"src"=>false}'
      )
    }
    it { is_expected.to contain_exec('update-midonet-repos').with(
        'command' => '/bin/true',
        'require' => '[Exec[apt_update]{:command=>"apt_update"}, Apt::Source[midonet]{:name=>"midonet"}, Apt::Source[midonet-openstack-integration]{:name=>"midonet-openstack-integration"}]'
      )
    }
  end
end
