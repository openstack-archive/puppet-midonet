require 'spec_helper'

describe 'midonet::agent' do
  context 'with default parameters' do
    let :facts do
      {
        :osfamily           => 'Debian',
        :lsbdistid          => 'Ubuntu',
        :lsbdistrelease     => '16.04',
      }
    end
    it { is_expected.to contain_class('midonet::repository') }
    it { is_expected.to contain_class('midonet::agent::install') }
    it { is_expected.to contain_class('midonet::agent::run') }
  end

end
