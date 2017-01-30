#!/usr/bin/env ruby
#^syntax detection

forge "https://forgeapi.puppetlabs.com"


## OpenStack modules

mod 'puppet-neutron',
  :git => 'https://github.com/openstack/puppet-neutron',
  :ref => 'stable/newton'

## External modules

mod 'puppetlabs/inifile'
mod 'puppetlabs/apt'
mod 'puppetlabs/java'
mod 'puppetlabs/stdlib'
mod 'puppetlabs/apache'
mod 'puppetlabs/firewall'
mod 'deric/zookeeper' , '0.6.1'
mod 'locp/cassandra' , '1.25.2'
mod 'puppetlabs/concat'
mod 'TubeMogul/curator'
mod 'elasticsearch/elasticsearch' , '0.13.2'
mod 'elasticsearch/logstash'
mod 'electrical/file_concat'
mod 'richardc/datacat'


mod 'midonet_openstack',
  :git => 'https://github.com/midonet/puppet-midonet_openstack',
  :ref => 'master'
