require 'spec_helper'

describe 'midonet::gateway::static' do
  context 'with parameters' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :lsbdistid      => 'Ubuntu',
        :lsbdistrelease => '16.04',
      }
    end
    let :params do
      {
        :network_id => 'example_netid',
        :cidr => '200.0.0.1/24',
        :gateway_ip => '200.0.0.1',
        :service_host => '127.0.0.1',
        :service_dir => '/tmp/status',
        :zookeeper_hosts => [ { 'ip' => '127.0.0.1', 'port' => '2181' } ],
        :api_port => '8181'
      }
    end
    it { is_expected.to contain_package('screen').with_ensure('installed') }
    it { is_expected.to contain_file('fake_uplink_script').with_ensure('present') }
    it { is_expected.to contain_file('midorc').with_ensure('present') }
    it { is_expected.to contain_file('functions').with_ensure('present') }
    it { is_expected.to contain_exec('/bin/bash /tmp/create_fake_uplink_l2.sh') }
  end
end
