require 'spec_helper_acceptance'

describe 'midonet class' do
  context 'with mem' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
        notice('removing MEM manager from Beaker test execution')
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end
  end
end
