require 'spec_helper'
require 'puppet'
require 'puppet/type/midonet_network'
require 'facter'

describe Puppet::Type::type(:midonet_network) do

  context 'on default values' do
    let(:resource) do
      Puppet::Type.type(:midonet_network).new(
        :netname         => 'testnet',
        :midonet_api_url => 'http://87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin',
        :tenant_name     => 'admin',
        :shared          => true,
        :external        => true,)
    end

    it 'assign the default values' do
      expect(resource[:midonet_api_url]).to eq 'http://87.23.43.2:8080/midonet-api'
      expect(resource[:username]).to eq 'admin'
      expect(resource[:password]).to eq 'admin'
      expect(resource[:tenant_name]).to eq 'admin'
      expect(resource[:shared]).to eq true
      expect(resource[:external]).to eq true

    end

  end

end
