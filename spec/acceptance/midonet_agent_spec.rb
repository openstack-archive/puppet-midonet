require 'spec_helper_acceptance'

describe 'midonet::agent class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should install the midonet agent without any errors' do
      pp = <<-EOS
      class { 'midonet::agent': manage_java => true }
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

    # JMX
    describe port(7200) do
      it { should be_listening }
    end
  end

  context

end
