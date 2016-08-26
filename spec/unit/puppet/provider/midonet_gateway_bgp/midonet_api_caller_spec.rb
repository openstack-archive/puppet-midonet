require 'spec_helper'

describe Puppet::Type.type(:midonet_gateway_bgp).provider(:midonet_api_caller) do

  let(:provider) { described_class.new(resource) }

  let(:resource) do
    Puppet::Type::type(:midonet_gateway_bgp).new(
    :router                  => 'edge_router',
    :midonet_api_url         => 'http://controller:8080/midonet-api',
    :username                => 'admin',
    :password                => 'admin',
    :bgp_local_as_number     => '64512',
    :bgp_neighbors           => [
      {
        'ip_address' => '200.100.98.7',
        'remote_asn' => '45237',
        'remote_net' => '200.100.98.0/24'
      },
      {
        'ip_address' => '182.24.63.2',
        'remote_asn' => '45235',
        'remote_net' => '182.24.63.0/24'
      },
    ],
    :bgp_advertised_networks => [ '200.100.0.0/24', '200.0.20.0/24' ] )
  end

  describe 'BGP configuration happy path' do

    # 1) Assign AS number to router
    # 2) Assign BGP neighbors to routers
    # 3) Advertise floating IP network
    # 4) Delete BGP neighbors
    # 5) De-advertise networks

    # Other parameters are returned by default, but only this one is needed for
    # testing purposes
    # More info: https://docs.midonet.org/docs/latest/rest-api/content/router.html
    let(:routers) {
      [
        {
         "id"   => "e6a53892-03bf-4f16-8212-e4d76ad204e3",
         "name" => "edge_router"
        }
      ]
    }
    # Other parameters are returned by default, but only this one is needed for
    # testing purposes
    # More info: https://docs.midonet.org/docs/latest/rest-api/content/bgp-peer.html
    let(:bgp_peers) {
      [
        {
          "id" => "4a5e4356-3417-4c60-9cf8-7516aedb7067",
        }
      ]
    }
    # Other parameters are returned by default, but only this one is needed for
    # testing purposes
    # More info: https://docs.midonet.org/docs/latest/rest-api/content/bgp-network.html
    let(:bgp_networks) {
      [
        {
          "id" => "4a5e4356-3417-4c60-9cf8-7516abcd1234",
        }
      ]
    }
    # Other parameters are returned by default, but only this one is needed for
    # testing purposes
    # More info: https://docs.midonet.org/docs/latest/rest-api/content/bgp-network.html
    let(:bgp_routes) {
      [
        {
          "id" => "4a268156-341d-ad41-9cf8-6892afed1234",
        }
      ]
    }

    before :each do
      allow(provider).to receive(:call_get_token).and_return('thisisafaketoken')
      allow(provider).to receive(:call_get_provider_router).and_return(routers)
      allow(provider).to receive(:call_assign_asn)
      allow(provider).to receive(:call_add_bgp_peer)
      allow(provider).to receive(:call_advertise_bgp_network)
      allow(provider).to receive(:call_get_bgp_peers).and_return(bgp_peers)
      allow(provider).to receive(:call_delete_bgp_peer)
      allow(provider).to receive(:call_get_bgp_networks).and_return(bgp_networks.map { |e| e['id'] })
      allow(provider).to receive(:call_delete_bgp_network)
      allow(provider).to receive(:call_get_bgp_routes).and_return(bgp_routes)
    end

    it 'follows happy path (BGP)' do
      expect(provider).to receive(:call_get_provider_router)
      expect(provider).to receive(:call_assign_asn)
      expect(provider).to receive(:call_add_bgp_peer).with(routers[0]['id'], '200.100.98.7', '45237')
      expect(provider).to receive(:call_add_bgp_peer).with(routers[0]['id'], '182.24.63.2', '45235')
      expect(provider).to receive(:call_advertise_bgp_network).with(routers[0]['id'], '200.100.0.0/24')
      expect(provider).to receive(:call_advertise_bgp_network).with(routers[0]['id'], '200.0.20.0/24')
      expect(provider).to receive(:call_get_bgp_peers).with(routers[0]['id'])
      #expect(provider).to receive(:call_delete_bgp_peer).with(bgp_peers[0]['id'])
      expect(provider).to receive(:call_get_bgp_networks).with(routers[0]['id'])
      #expect(provider).to receive(:call_delete_bgp_network).with(bgp_networks[0]['id'])
      expect(provider).to receive(:call_get_bgp_routes).with(routers[0]['id'])
      expect(provider).to receive(:call_add_bgp_route).with(routers[0]['id'], '200.100.98.0/24')
      expect(provider).to receive(:call_add_bgp_route).with(routers[0]['id'], '182.24.63.0/24')
      expect(provider).to receive(:call_add_default_routes).with(routers[0]['id'], { 'ip_address' => '200.100.98.7', 'remote_asn' => '45237', 'remote_net' => '200.100.98.0/24' } )
      expect(provider).to receive(:call_add_default_routes).with(routers[0]['id'], { 'ip_address' => '182.24.63.2', 'remote_asn' => '45235', 'remote_net' => '182.24.63.0/24' } )
      #expect(provider).to receive(:call_delete_bgp_route).with('4a268156-341d-ad41-9cf8-6892afed1234')
      provider.create
      #provider.destroy
    end

    it 'deletes BGP peers, and stops advertising the floating IP network' do
      expect(provider).to receive(:call_get_provider_router)
      expect(provider).to receive(:call_get_bgp_peers).with(routers[0]['id'])
      expect(provider).to receive(:call_delete_bgp_peer).with(bgp_peers[0]['id'])
      expect(provider).to receive(:call_get_bgp_networks).with(routers[0]['id'])
      expect(provider).to receive(:call_delete_bgp_network).with(bgp_networks[0]['id'])
      provider.destroy
    end

    it 'checks if a given provider router exists' do
      expect(provider).to receive(:call_get_provider_router)
      provider.exists?
    end
  end
end
