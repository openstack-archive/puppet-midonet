require 'spec_helper_acceptance'

describe 'midonet::analytics class' do
  context 'with mandatory parameters (default params not overwritten)' do
    # Using puppet_apply as a helper
    it 'should install the midonet analytics without any errors' do
      pp = <<-EOS
      class { 'midonet::analytics':
        is_mem       => true,
        manage_repo  => true,
        mem_username => 'calsoft',
        mem_password => '3adfF3cd'
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('logstash') do
      it { should be_installed }
    end

    describe package('elasticsearch') do
      it { should be_installed }
    end
  end

  context

end
