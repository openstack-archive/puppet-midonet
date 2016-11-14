require 'spec_helper'

describe 'midonet::mem' do
  context 'with default parameters' do
     let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04',
        :kernel                 => 'Linux',
        :ipaddress              => '192.168.79.13',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'gateway',
        :memorysize             => '2048',
        :lsbdistid              => 'trusty',
        :lsbdistrelease         => '14.04',
        :puppetversion          => Puppet.version
      }
    end
    it { is_expected.to contain_package('midonet-manager').with(
        'ensure'  => 'installed',
      ) }
  end
end
