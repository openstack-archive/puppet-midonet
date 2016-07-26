require 'spec_helper'
require 'puppet'
require 'puppet/type/midonet_gateway_bgp'
require 'facter'

describe Puppet::Type::type(:midonet_gateway_bgp) do

  context 'on default values (bgp)' do
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
        },
        {
          'ip_address' => '182.24.63.2',
          'remote_asn' => '45235',
        },
      ],
      :bgp_advertised_networks => [ '200.0.0.0/24', '200.0.20.0/24' ] )
    end

    it 'assign the default values' do
      expect(resource[:username]).to eq 'admin'
      expect(resource[:password]).to eq 'admin'
      expect(resource[:router]).to eq 'edge_router'
      expect(resource[:bgp_local_as_number]).to eq '64512'
    end
  end

  context 'on invalid api url' do
    it do
      expect {
        Puppet::Type.type(:midonet_gateway_bgp).new(
        :router          => 'edge_router',
        :midonet_api_url => '87.23.43.2:8080/midonet-api',
        :username        => 'admin',
        :password        => 'admin')
      }.to raise_error(Puppet::ResourceError)
    end
  end

  context 'on invalid bgp neighbors' do
    it do
      expect {
        Puppet::Type.type(:midonet_gateway_bgp).new(
        :router        => 'edge_router',
        :bgp_neighbors => '["12.13.14.15"]',
        :username      => 'admin',
        :password      => 'admin')
      }.to raise_error(Puppet::ResourceError)
    end
  end

  context 'on advertising invalid networks' do
    it do
      expect {
        Puppet::Type.type(:midonet_gateway_bgp).new(
        :router                  => 'edge_router',
        :bgp_advertised_networks => ["12.13.14.15", "11.33.44.55/12"],
        :username                => 'admin',
        :password                => 'admin')
      }.to raise_error(Puppet::ResourceError)
    end
  end

end
