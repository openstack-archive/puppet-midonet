require 'uri'
require 'facter'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:midonet_network) do
  @doc = %q{Register a Network to a Neutron
    through the MidoNet API

      Example:

        midonet_network {'netname':
          $midonet_api_url     => 'http://controller:8080',
          $username            => 'admin',
          $password            => 'admin',
          $tenant_name         => 'admin',
          $shared              => true,
          $external            => true,
        }
  }
  ensurable

  newparam(:netname, :namevar => true) do
    desc 'Name of the networks that wants to be created in Neutron'
    validate do |value|
      unless value =~ /\w+/
        raise ArgumentError, "'%s' is not a valid network name" % value
      end
    end
  end

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
    validate do |value|
      unless value =~ /^[\w\-\_]+$/
        raise ArgumentError, "'%s' is not a valid username" % value
      end
    end
  end

  newparam(:password) do
    desc 'Password of the admin user in keystone'
    validate do |value|
      unless value =~ /^[\w\-\_]+$/
        raise ArgumentError, "'%s' is not a valid password" % value
      end
    end
  end

  newparam(:tenant_name) do
    desc 'Tenant name of the admin user'
    defaultto :'admin'
    validate do |value|
      unless value =~ /^[\w\-\_]+$/
        raise ArgumentError, "'%s' is not a tenant name" % value
      end
    end
  end

  newparam(:external, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Switch to mark the network as external or not"
  end

  newparam(:shared, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Switch to mark the network as shared or not"
  end


end
