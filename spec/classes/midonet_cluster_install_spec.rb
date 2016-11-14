require 'spec_helper'

describe 'midonet::cluster::install' do
  context 'with parameters' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :lsbdistid      => 'Ubuntu',
        :lsbdistrelease => '16.04',
        :puppetversion  => Puppet.version
      }
    end
    it { is_expected.to contain_package('midonet-cluster').with(
      'ensure' => 'present',
      'name'   => 'midonet-cluster',
      ) }
  end
end
