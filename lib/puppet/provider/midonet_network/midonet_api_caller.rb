if RUBY_VERSION == '1.8.7'
  require 'rubygems'
end

require 'uri'
require 'faraday' if Puppet.features.faraday?
require 'json'

Puppet::Type.type(:midonet_network).provide(:midonet_api_caller) do

  confine :feature => :faraday

  def create
    define_connection(resource[:midonet_api_url])
    tenants = call_get_tenant(resource[:tenant_name])
    if tenants.empty?
      raise "Tenant with specified name #{resource[:tenant_name]} does not exist"
    end
    tenant_id = tenants[0]['id']
    network = call_get_network(resource[:netname],tenant_id)
    if !network.empty?
      raise "Network #{resource[:netname]} for tenant #{resource[:tenant_name]} already exists"
    end

    message = Hash.new
    message['name'] = resource[:netname]
    message['tenant_id'] = tenant_id
    message['shared'] = resource[:shared]
    message['external'] = resource[:external]

    call_create_network(message)
  end

  def destroy
    define_connection(resource[:midonet_api_url])

    tenants = call_get_tenant(resource[:tenant_name])

    if tenants.empty?
      return
    end
    tenant_id = tenants[0]['id']
    network = call_get_network(resource[:netname],tenant_id)
    if network.empty?
      return
    else
      call_delete_network(network)
    end
  end

  def exists?
    define_connection(resource[:midonet_api_url])

    tenants = call_get_tenant(resource[:tenant_name])
    if tenants.empty?
      return
    end
    tenant_id = tenant[0]['id']
    network = call_get_network(resource[:netname],tenant_id)
    if network.empty?
      return false
    else
      return true
    end

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
      req.url "/midonet-api/login"
    end
    return JSON.parse(res.body)['key']
  end

  def call_get_tenant(tenant_name)
    res = @connection.get do |req|
      req.url "/midonet-api/tenants"
    end

    output = JSON.parse(res.body)
    return output.select{ |tenant| tenant['name'] == tenant_name.to_s }
  end

  def call_get_network(network_name,tenant_id)
    res = @connection.get do |req|
      req.url "/midonet-api/neutron/networks"
    end

    output = JSON.parse(res.body)
    return output.select{ |network| network['name'] == network_name.to_s and network['tenant_id'] == tenant_id }
  end

  def call_get_networks()
    res = @connection.get do |req|
      req.url "/midonet-api/neutron/networks"
    end

    output = JSON.parse(res.body)
    return output
  end

  def call_create_network(message)

    res = @connection.post do |req|
      req.url "/midonet-api/neutron/networks"
      req.headers['Content-Type'] = "application/vnd.org.midonet.Network-v1+json"
      req.body = message.to_json
    end

    return call_get_networks()

  end


  def call_delete_network(network_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/neutron/networks/#{network_id}"
    end
  end

  private :call_create_network,
          :call_delete_network,
          :call_get_tenant,
          :call_get_network,
          :define_connection

end
