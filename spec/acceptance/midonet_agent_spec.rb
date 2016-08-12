require 'spec_helper_acceptance'

describe 'midonet::agent class' do
  context 'with mandatory parameters (default params not overwritten)' do
    # Using puppet_apply as a helper
    it 'should install the midonet agent without any errors' do
      pp = <<-EOS
      include ::midonet::repository
      class { 'midonet_openstack::role::nsdb':
      }
      class { 'midonet::agent':
        zookeeper_hosts => [ { 'ip' => '127.0.0.1', 'port' => '2181' } ],
        controller_host => '127.0.0.1',
        metadata_port   => '8181',
        shared_secret   => 'SHARED_SECRET',
        manage_java     => false,
        require         => Class['midonet_openstack::role::nsdb'],
        max_heap_size   => "256M"
      }
      include ::midonet::agent::scrapper
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('midolman') do
      it { should be_installed }
    end

    describe service('midolman') do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context

end
