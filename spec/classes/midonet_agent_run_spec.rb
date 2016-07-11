require 'spec_helper'

describe 'midonet::agent::run' do
  context 'with default parameters' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :lsbdistid      => 'Ubuntu',
        :lsbdistrelease => '16.04',
      }
    end
    it { is_expected.to contain_file('/etc/midolman/midolman.conf').with(
        'ensure'  => 'present',
      ) }
    it { is_expected.to contain_service('midolman').with_ensure('running') }
  end
end
