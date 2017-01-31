#    Copyright 2015 Midokura SARL, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

require 'netaddr'
require 'socket'

module Puppet::Parser::Functions
  newfunction(:cidr2iface, :type => :rvalue, :doc => <<-EOS
    This function returns a iface name or will raise an error if no iface matches
    EOS
  ) do |argv|
    unless argv[0] =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/[0-9]{,2}$/
      raise ArgumentError, "#{argv[0]} is not a valid CIDR"
    end
    ifaces = Socket.getifaddrs.map { |i| {ip: i.addr.ip_address,name: i.name,cidr: NetAddr::CIDR::create("#{i.addr.ip_address} #{i.netmask.ip_address}").to_s } if i.addr.ipv4? }.compact
    matching_iface = ifaces.select{ |i| i[:cidr] == argv[0]}.first
    return matching_iface[:name] unless matching_ifaces.nil?
    raise ("No Matching iface found")
  end
end
