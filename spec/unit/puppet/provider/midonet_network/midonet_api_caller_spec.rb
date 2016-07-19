require 'spec_helper'

describe Puppet::Type.type(:midonet_network).provider(:midonet_api_caller) do

  let(:provider) { described_class.new(resource) }

  let(:resource) { Puppet::Type.type(:midonet_network).new(
    {
      :ensure          => :present,
      :netname         => 'testnet',
      :midonet_api_url => 'http://controller:8080',
      :username        => 'admin',
      :password        => 'admin',
      :tenant_name     => 'admin',
      :shared          => true,
      :external        => true
    }
  )}

  describe 'network happy path' do
    # - Tenant Existing
    # - Network not previously existing

    let(:tenants) {
      [
        {
          "name" => "admin",
          "id"   => "bd69f96a-005b-4d58-9f6c-b8dd9fbb6339",
        }
      ]
    }

    let(:networks) {
      [
        {
          "name"      => "testnet",
          "id"        => "by82a88d-005b-4d58-9f6c-aaaaaaaa1111",
          "tenant_id" => "admin",
          "shared"    => "true",
          "external"  => "true"
        }
      ]
    }


    before :each do
      allow(provider).to receive(:call_get_tenant).and_return(tenants)
      allow(provider).to receive(:call_get_network).and_return(networks)
      allow(provider).to receive(:call_delete_network)
      allow(provider).to receive(:call_create_network)
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
    end

    it 'registers the network successfully' do
      # Expectations over 'create' call
      expect(provider).to receive(:call_get_tenant).and_return(tenants)
      expect(provider).to receive(:call_get_network).and_return([])
      expect(provider).to receive(:call_create_network).with({'name' => 'testnet', 'tenant_id' => 'bd69f96a-005b-4d58-9f6c-b8dd9fbb6339', 'shared' => true, 'external' => true})
      provider.create
    end

    it 'unregisters the network successfully' do
      # Expectations over 'create' call
      expect(provider).to receive(:call_get_tenant).and_return(tenants)
      expect(provider).to receive(:call_get_network).and_return(networks)
      expect(provider).to receive(:call_delete_network).and_return([])
      provider.destroy
    end


  end



end
