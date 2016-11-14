require 'spec_helper'

describe 'midonet::agent::install' do
  let :facts do
    {
      :osfamily        => 'Debian',
      :lsbdistid       => 'Ubuntu',
      :lsbdistrelease  => '16.04',
      :lsbdistcodename => 'xenial',
      :puppetversion  => Puppet.version
    }
  end

  context 'with default parameters' do
    it { is_expected.to contain_package('midolman').with(
        'ensure'  => 'present',
      ) }
  end

  context 'with custom parameters' do
    let :params do
      {
        :manage_java => true,
      }
    end
    it { is_expected.to contain_package('midolman').with_ensure('present') }
  end
end
