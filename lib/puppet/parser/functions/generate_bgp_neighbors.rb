#    Copyright 2016 Midokura SARL, Inc.
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
#
module Puppet::Parser::Functions
  newfunction(:generate_bgp_neighbors, :type => :rvalue, :doc => <<-EOS
    This function returns an array that can be understood by the
    midonet_gateway_bgp custom type in the bgp_neighbors parameter
    EOS
  ) do |argv|
    ip_addresses = argv[0]
    remote_asns  = argv[1]
    remote_nets  = argv[2]
    result = []

    # Check that all hashes have the same length
    raise ArgumentError, 'All 3 arrays must have the same legth' unless ip_addresses.length == remote_asns.length && ip_addresses.length == remote_nets.length

    ip_addresses.length.times do |k|
      result.push({ 'ip_address' => ip_addresses[k], 'remote_asn' => remote_asns[k], 'remote_net' => remote_nets[k] })
    end

    return result
  end
end
