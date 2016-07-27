require 'spec_helper_acceptance'

describe 'midonet::cli class' do
  context 'without mem' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
        class {'midonet::cli':
          api_endpoint => 'http://127.0.0.1:8181/midonet-api',
          username     => 'admin',
          password     => 'admin',
          tenant_name  => 'admin',
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

      describe package('python-midonetclient') do
        it { should be_installed }
      end

      describe file('/root/.midonetrc') do
        its (:content) { should match /api_url=http:\/\/127.0.0.1:8181\/midonet-api/ }
        its (:content) { should match /username=admin/ }
        its (:content) { should match /password=admin/ }
        its (:content) { should match /project_id=admin/ }
      end


  end



end
