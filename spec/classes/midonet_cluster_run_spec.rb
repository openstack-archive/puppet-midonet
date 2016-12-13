require 'spec_helper'

describe 'midonet::cluster::run' do
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
        :zookeeper_hosts       => ['{ "ip" => "127.0.0.1", "port" => "2181" }'],
        :cassandra_servers      => [ '127.0.0.1' ],
        :cassandra_rep_factor => '3',
        :keystone_admin_token => 'ADMIN_TOKEN',
        :keystone_host => '127.0.0.1',
      }
    end
    it { is_expected.to contain_exec('/bin/bash /tmp/mn-cluster_config.sh') }
    it { is_expected.to contain_file('/tmp/mn-cluster_config.sh').with_ensure('present') }
    it { is_expected.to contain_file('set_config').with(
        'ensure'  => 'present',
        'path'    => '/etc/midonet/midonet.conf',
      ) }
    it { is_expected.to contain_service('midonet-cluster').with(
        'ensure'  => 'running',
        'enable' => 'true',
        'name'    => 'midonet-cluster'
      ) }
  end
end
