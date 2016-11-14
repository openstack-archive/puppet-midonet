require 'spec_helper'

describe 'midonet::agent::run' do
  context 'with default parameters' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :lsbdistid      => 'Ubuntu',
        :lsbdistrelease => '16.04',
        :puppetversion  => Puppet.version

      }
    end
    let :params do
      {
        :zookeeper_hosts    => [ { 'ip' => '127.0.0.1' } ],
        :controller_host    => '127.0.0.1',
        :metadata_port      => '8118',
        :shared_secret      => 'SHARED_SECRET',
      }
    end
    it { is_expected.to contain_file('agent_config').with_ensure('present') }
    it { is_expected.to contain_file('jvm_config').with_ensure('present') }
    it { is_expected.to contain_service('midolman').with_ensure('running') }
  end
end
