require 'spec_helper'


describe 'host_id' do
  let(:output) do
    <<-EOF
#Mon Aug 22 16:42:19 UTC 2016
host_uuid=41b4d082-daf8-40bb-8812-504a0e9e5dac
EOF
  end

  it 'should work without errors' do
    allow(File).to receive(:read).and_return('test')
    allow(File).to receive(:read).with('/etc/midonet_host_id.properties').and_return(output)

    is_expected.to run.with_params().and_return('41b4d082-daf8-40bb-8812-504a0e9e5dac')

  end

end
