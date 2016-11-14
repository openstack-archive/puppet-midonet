require 'spec_helper'

describe 'midonet::gateway::static' do
  context 'with parameters' do
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
      :nic            => 'enp0s3',
      :fip            => '200.200.200.0/24',
      :edge_router    => 'edge-router',
      :veth0_ip       => '172.19.0.1',
      :veth1_ip       => '172.19.0.2',
      :veth_network   => '172.19.0.0/30',
      :scripts_dir    => '/tmp',
      :uplink_script  => 'create_fake_uplink_l2.sh',
      :ensure_scripts =>  'present',
      }
    end
    it { is_expected.to contain_file('fake_uplink_script').with_ensure('present') }
    it { is_expected.to contain_exec('run gateway static creation script').with(
        'command' => '/bin/bash -x /tmp/create_fake_uplink_l2.sh 2>&1 | tee /tmp/bash.out'
      ) }
  end
end
