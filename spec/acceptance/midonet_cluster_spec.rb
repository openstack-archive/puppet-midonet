require 'spec_helper_acceptance'

describe 'midonet::cluster class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should install the midonet cluster without any errors' do
      pp = <<-EOS
      include ::midonet::repository
      class { 'midonet_openstack::role::nsdb':
        client_ip => '127.0.0.1'
      }
      class { 'midonet::cluster':
        zookeeper_hosts       => [{ 'ip' => '127.0.0.1', 'port' => '2181' }],
        cassandra_servers     => ['127.0.0.1'],
        cassandra_rep_factor  => 1,
        keystone_admin_token  => 'testmido',
        keystone_host         => '127.0.0.1',
        max_heap_size         => '256M',
       }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('midonet-cluster') do
      it { should be_installed }
    end

    describe service('midonet-cluster') do
      it { should be_enabled }
      it { should be_running }
    end

  end

end
