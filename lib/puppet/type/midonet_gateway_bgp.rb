require 'uri'
require 'facter'

Puppet::Type.newtype(:midonet_gateway_bgp) do
  @doc = %q{This type is used to configure a gateway node, considering the
  uplink is of type BGP. What it does:
    1) Assign an AS number to the edge router
    2) Assign BGP peers
    3) Advertise BGP networks

    Usage:

    midonet_gateway_bgp { 'edge_router':
      bgp_local_as_number     => '65432',
      bgp_advertised_networks => [
        '200.0.0.0/24',
        '12.0.140.0/16',
      ],
      bgp_neighbors           => [
        {
          'ip_address' => '200.0.1.1',
          'remote_asn' => '34512'
        },
        {
          'ip_address' => '12.0.140.1',
          'remote_asn' => '24125'
        }
      ],
      midonet_api_url         => 'http://controller:8181',
      username                => 'admin',
      password                => 'admin',
    }
  }

  ensurable

  newparam(:bgp_local_as_number) do
    desc "AS number of the local BGP autonomous system.  If you have an RIR
      registered AS number, use it.  If you don't have an RIR registered AS
      number, use any of the RFC 1930's reserved AS number.  It should be an
      integer.  Only applicable when uplink_type=='bgp'."
    validate do |value|
      unless value =~ /^\d+$/
        raise ArgumentError, "'%s' is not a valid AS number" % value
      end
    end
  end

  newparam(:bgp_advertised_networks) do
    desc "Networks advertised to the remote BGP autonomous system.  This usually
      should be the same as floating IP networks defined in neutron.  It should
      be an array of strings, each of which should be a network address
      in either \"IP/Prefix_Length\" notation (\"192.0.2.0/24\") or
      \"IP/Subnet_Mask\" nonation(\"192.0.2.0/255.255.255.0\").  Only applicable
      when uplink_type=='bgp'.  A more elaborate example will be:

        [ '192.0.2.128/25', '198.51.100.128/25', '203.0.113.128/25' ]"
    validate do |value|
      unless value.class == Array && value.length > 0
        raise ArgumentError, "#{value} is not an Array"
      else
        value.each do |e|
          unless e.class == String && e =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/\d+$/
            raise ArgumentError, "#{e} is not a valid IP address"
          end
        end
      end
    end
  end

  newparam(:bgp_neighbors) do
    desc " An array containing hashes that describe a remote BGP peer. These
    hashes must have two parameters:
     - 'ip_address': IP address of the peer
     - 'remote_asn': Peer's AS number

    A real life example will look like:
    [
      {
        'ip_address' => '203.0.113.1',
        'remote_asn' => '64513'
      },
      {
        'ip_address' => '198.51.100.1',
        'remote_asn' => '64514'
      }
    ]
    "
    validate do |value|
      unless value.class == Array && value.length > 0
        raise ArgumentError, "'%s' is not an array" % value
      else
        value.each do |e|
          unless e.class == Hash && e.key?("ip_address") && e.key?("remote_asn")
            raise ArgumentError, "'%s' doesn't contain parameters 'ip_address' and/or 'remote_asn'" % value
          else
            unless e["ip_address"] =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
              raise ArgumentError, "#{e['ip_address']} is not a valid IP address"
            end
            unless e["remote_asn"] =~ /^\d+$/
              raise ArgumentError, "#{e['remote_asn']} is not a valid AS number"
            end
          end
        end
      end
    end
  end

  autorequire(:package) do ['midolman'] end

  newparam(:midonet_api_url) do
    desc 'MidoNet API endpoint to connect to'
    validate do |value|
      unless value =~ /\A#{URI::regexp(['http', 'https'])}\z/
        raise ArgumentError, "'%s' is not a valid URI" % value
      end
    end
  end

  newparam(:username) do
    desc 'Username of the admin user in keystone'
    defaultto 'admin'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid username" % value
      end
    end
  end

  newparam(:password) do
    desc 'Password of the admin user in keystone'
    defaultto 'admin'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid password" % value
      end
    end
  end

  newparam(:router, :namevar => true) do
    desc "The MidoNet's internal Provider router that acts as the gateway router of the cloud"
    defaultto 'MidoNet Provider Router'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid router name" % value
      end
    end
  end

end
