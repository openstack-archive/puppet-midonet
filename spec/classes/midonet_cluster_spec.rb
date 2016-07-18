require 'spec_helper'

describe 'midonet::cluster' do
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
        :zookeeper_hosts       => ['{ "ip" => "127.0.0.1", "port" => "2181" }'],
        :cassandra_servers      => [ '127.0.0.1' ],
        :cassandra_rep_factor => '3',
        :keystone_admin_token => 'ADMIN_TOKEN',
        :keystone_host => '127.0.0.1',
      }
    end
    it { is_expected.to contain_class('midonet::cluster::install') }
    it { is_expected.to contain_class('midonet::cluster::run') }
  end
end
