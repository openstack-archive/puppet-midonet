if RUBY_VERSION == '1.8.7'
    require 'rubygems'
end

require 'uri'
require 'faraday'
require 'json'
require 'ipaddr'

Puppet::Type.type(:midonet_gateway_bgp).provide(:midonet_api_caller) do

  def create

    define_connection(resource[:midonet_api_url])

    # Get the edge router uuid
    provider_router = call_get_provider_router()[0]
    puts "MYDEBUG >> provider_router   = #{provider_router}"
    provider_router_id = provider_router['id']

    # Assign local ASN to the provider router
    asn = provider_router['asNumber']
    call_assign_asn(provider_router, resource[:bgp_local_as_number]) unless asn == resource[:bgp_local_as_number]
    puts "MYDEBUG >> Assigning ASN #{resource[:bgp_local_as_number]} to router #{provider_router_id}"

    # Sync BGP peers
    bgp_neighbors = call_get_bgp_peers(provider_router_id)
    m = Array.new
    bgp_neighbors.each do |bgp_neighbor|
      n = { "ip_address" => bgp_neighbor["address"],
        "remote_asn" => bgp_neighbor["asNumber"] }
      m << n
    end
    tbd_peers = m - resource[:bgp_neighbors]
    puts "MYDEBUG >> Deleting BGP peers #{tbd_peers}"
    tba_peers = resource[:bgp_neighbors] - m
    puts "MYDEBUG >> Adding BGP peers #{tba_peers}"

    tba_peers.each { |a| call_add_bgp_peer(provider_router_id, a['ip_address'], a['remote_asn']) }
    tbd_peers.each do |d|
      bgp_peer_id = bgp_neighbors.select { |bgp_neighbor| bgp_neighbor['asNumber'] == d['remote_asn'] }[0]["id"]
      call_delete_bgp_peer(bgp_peer_id)
    end

    # Advertise floating IP networks
    bgp_advertised_networks = call_get_bgp_networks(provider_router_id)
    puts "MYDEBUG >> Existing BGP networks are #{bgp_advertised_networks}"
    j = Array.new
    bgp_advertised_networks.each do |bgp_advertised_network|
      k = [ bgp_advertised_network["subnetAddress"], bgp_advertised_network["subnetLength"] ].join("/")
      j << k
    end
    puts "MYDEBUG >> bgp_advertised_networks is worth #{bgp_advertised_networks}"
    puts "MYDEBUG >> j is worth #{j}"
    tbd_bgp_networks = j - resource[:bgp_advertised_networks]
    tba_bgp_networks = resource[:bgp_advertised_networks] - j
    tbd_bgp_networks.each do |d|
      bgp_network_id = bgp_advertised_networks.select { |bgp_advertised_network| bgp_advertised_network['subnetAddress'] == d.split("/")[0] && bgp_advertised_network['subnetLength'] == d.split("/")[1] }[0]["id"]
      call_delete_bgp_network(bgp_network_id)
    end
    tba_bgp_networks.each { |a| call_advertise_bgp_network(provider_router_id, a) }
    puts "MYDEBUG >> Deleting BGP networks #{tbd_bgp_networks}"
    puts "MYDEBUG >> Advertising BGP networks #{tba_bgp_networks}"

    # Get routes and see which ones do we need to actually create
    dup_routes = Array.new
    existing_bgp_routes = call_get_bgp_routes(provider_router_id)
    neighbors_remote_net = resource[:bgp_neighbors].map { |x| x['remote_net']  }.uniq
    puts "MYDEBUG >> neighbors_remote_net is #{neighbors_remote_net}"
    existing_bgp_routes.each do |r|
      dup_routes << r if neighbors_remote_net.select { |net| net == "#{r['dstNetworkAddr']}/#{r['dstNetworkLength']}" }
    end
    # Add routes to remote BGP peers
    tba_routes = neighbors_remote_net - dup_routes.map { |dr| "#{dr['dstNetworkAddr']}/#{dr['dstNetworkLength']}" }
    tba_routes.each do |r|
      call_add_bgp_route(provider_router_id, r)
    end
  end

  def destroy

    define_connection(resource[:midonet_api_url])

    # Get the edge router uuid
    provider_router_id = call_get_provider_router()[0]['id']

    # "Unset" asNumber by setting it to -1 (default value)
    call_assign_asn(provider_router_id, "-1")

    # Remove BGP peers from router
    bgp_peers = call_get_bgp_peers(provider_router_id)
    bgp_peers.each do |bgp_peer|
      call_delete_bgp_peer(bgp_peer["id"])
    end

    # De-advertise floating IP networks
    bgp_networks = call_get_bgp_networks(provider_router_id)
    bgp_networks.each do |bgp_network|
      call_delete_bgp_network(bgp_network)
    end
  end

  def exists?

    define_connection(resource[:midonet_api_url])

    # Get the edge router uuid
    provider_router = call_get_provider_router()[0]
    provider_router_id = provider_router['id']
    result_array = Array.new

    # Check if local ASN is the same
    result_array.push(provider_router["asNumber"] == resource[:bgp_local_as_number])
    # Check if BGP neighbors are the same
    bgp_neighbors = call_get_bgp_peers(provider_router_id)
    m = Array.new
    bgp_neighbors.each do |bgp_neighbor|
      n = { "ip_address" => bgp_neighbor["address"],
        "remote_asn" => bgp_neighbor["asNumber"] }
      m << n
    end
    result_array.push(m == resource[:bgp_neighbors])
    # Check if advertised networks are the same
    bgp_advertised_networks = call_get_bgp_networks(provider_router_id)
    j = Array.new
    bgp_advertised_networks.each do |bgp_advertised_network|
      k = [ bgp_advertised_network["subnetAddress"], bgp_advertised_network["subnetLength"] ].join("/")
      j << k
    end
    result_array.push(j == resource[:bgp_advertised_networks])

    # Test if all tests are positive
    return result_array.uniq == [true]

  end

  def define_connection(url)

    @connection = Faraday.new(:url => url,
                              :ssl => { :verify =>false }) do |builder|
        builder.request(:retry, {
          :max        => 5,
          :interval   => 0.05,
          :exceptions => [
            Faraday::Error::TimeoutError,
            Faraday::ConnectionFailed,
            Errno::ETIMEDOUT,
            'Timeout::Error',
          ],
        })
        builder.request(:basic_auth, resource[:username], resource[:password])
        builder.adapter(:net_http)
    end

    @connection.headers['X-Auth-Token'] = call_get_token()
  end

  def call_get_token()
    res = @connection.get do |req|
      req.headers['X-Auth-Project'] = resource[:tenant_name]
      req.url "/midonet-api/login"
    end
    return JSON.parse(res.body)['key']
  end

  def call_get_provider_router()
    res = @connection.get do |req|
      req.url "/midonet-api/routers"
    end
    output = JSON.parse(res.body)
    provider_router = output.select { |r| r['name'] == resource[:router]}
    raise "Router #{resource[:router]} does not exist" if provider_router.empty?
    return provider_router
  end

  def call_assign_asn( provider_router, bgp_local_as_number )
    res = @connection.put do |req|
      req.url "/midonet-api/routers/#{provider_router['id']}"
      req.headers['Content-Type'] = "application/vnd.org.midonet.Router-v3+json"
      req.body = {
        'asNumber' => bgp_local_as_number,
        'adminStateUp' => provider_router['adminStateUp'],
        'inboundFilterId' => provider_router['inboundFilterId'],
        'inboundMirrorIds' => provider_router['inboundMirrorIds'],
        'name' => provider_router['name'],
        'outboundFilterId' => provider_router['outboundFilterId'],
        'outboundMirrorIds' => provider_router['outboundMirrorIds'],
        'tenantId' => provider_router['tenantId']
      }.to_json
    end
  end

  def call_add_bgp_peer( provider_router_id, ip_address, remote_asn )
    res = @connection.post do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/bgp_peers"
      req.headers['Content-Type'] = "application/vnd.org.midonet.BgpPeer-v1+json"
      req.body = { 'address' => ip_address,
                   'asNumber' => remote_asn }.to_json
    end
  end

  def call_add_bgp_route( provider_router_id, remote_network )
    net_address, net_length = remote_network.split("/")
    port = ''
    router_ports = call_get_router_ports(provider_router_id)
    router_ports.each do |rp|
      port = rp if IPAddr.new("#{remote_network}").include?(rp['portAddress'])
    end
    unless port.empty?
      res = @connection.post do |req|
        req.url "/midonet-api/routers/#{provider_router_id}/routes"
        req.headers['Content-Type'] = "application/vnd.org.midonet.Route-v1+json"
        req.body = {
          'dstNetworkAddr' => net_address,
          'dstNetworkLength' => net_length,
          'nextHopPort' => port['id'],
          'srcNetworkAddr' => '0.0.0.0',
          'srcNetworkLength' => '0',
          'type' => 'Normal',
          'weight' => '71'
        }.to_json
      end
    end
  end

  def call_advertise_bgp_network( provider_router_id, bgp_advertised_network )
    subnet_address, subnet_length = bgp_advertised_network.split("/")
    res = @connection.post do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/bgp_networks"
      req.headers['Content-Type'] = "application/vnd.org.midonet.BgpNetwork-v1+json"
      req.body = { 'subnetAddress' => subnet_address,
                   'subnetLength'  => subnet_length }.to_json
    end
  end

  def call_delete_bgp_peer(bgp_peer_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/bgp_peers/#{bgp_peer_id}"
    end
  end

  def call_delete_bgp_network(bgp_network)
    res = @connection.delete do |req|
      req.url "/midonet-api/bgp_networks/#{bgp_network}"
    end
  end

  def call_delete_bgp_route(route)
    res = @connection.delete do |req|
      req.url "/midonet-api/routes/#{route}"
    end
  end

  def call_get_bgp_peers(provider_router_id)
    res = @connection.get do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/bgp_peers"
    end
    output = JSON.parse(res.body)
    return output
  end

  def call_get_router_ports(provider_router_id)
    res = @connection.get do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/ports"
    end
    output = JSON.parse(res.body)
    return output
  end

  def call_get_bgp_routes(provider_router_id)
    res = @connection.get do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/routes"
    end
    output = JSON.parse(res.body)
    return output
  end

  def call_get_bgp_networks(provider_router_id)
    res = @connection.get do |req|
      req.url "/midonet-api/routers/#{provider_router_id}/bgp_networks"
    end
    output = JSON.parse(res.body)
    return output
  end

  private :call_get_provider_router
          :define_connection
          :call_assign_asn
          :call_add_bgp_peer
          :call_get_bgp_networks
          :call_get_bgp_peers
          :call_delete_bgp_network
          :call_delete_bgp_peer
          :call_advertise_bgp_network

end
