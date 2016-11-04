# midonet

#### Table of Contents

1. [Overview - What is the midonet module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with midonet](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
6. [Contributors - Those with commits](#contributors)


## Overview

This Puppet module is maintained by [Midokura](http://www.midokura.com)
and is used to flexibly configure and manage all MidoNet components.

To understand all MidoNet components and how they relate to each other,
check out the [MidoNet Reference Architecture](http://docs.midonet.org/docs/latest/reference-architecture/content/index.html).


## Module Description

The midonet module is a thorough attempt to make Puppet capable of managing
the entirety of MidoNet. This includes manifests to provision both open source
and enterprise components:

* MidoNet Cluster (formerly known as the MidoNet API)
* MidoNet CLI
* MidoNet Agent (also known as Midolman)
* MEM
* MEM Insights

Uplink configuration for gateway nodes is also set up through the use of this
module. Currently both static and BGP uplinks are supported.

This module is tested in combination with other modules needed to build and
leverage a MidoNet installation.

## Setup

**What the neutron module affects:**

* [MidoNet](https://www.midonet.org/), which replaces the default plugin for
Neutron.

### Prerequisites

To use this module correctly, the following dependencies have to be met:

* Have the gems `faraday` and `multipart-post` installed correctly (if using
Puppet 4.x use the `gem` executable from Puppet's main path)
* Have a working Zookeeper & Cassandra setup

### Installing midonet

```shell
puppet module install midonet-midonet
```

### Beginning with midonet

A very basic installation of MidoNet on a controller node looks like the
following:

```puppet
include ::midonet::repository

class { '::midonet::cluster':
  zookeeper_hosts      => [ { 'ip' => '127.0.0.1' } ],
  cassandra_servers    => [ { 'ip' => '127.0.0.1' } ],
  cassandra_rep_factor => '1',
  keystone_admin_token => 'token',
  keystone_host        => '127.0.0.1',
} ->
class { '::midonet::cli':
  username => 'admin',
  password => 'safe_password',
} ->
class { '::midonet::agent':
  controller_host => '127.0.0.1',
  metadata_port   => '8775',
  shared_secret   => 'shared_secret',
  zookeeper_hosts => [ { 'ip' => '127.0.0.1' } ],
}
```

And on compute nodes:

```puppet
include ::midonet::repository

class { '::midonet::agent':
  controller_host => '127.0.0.1',
  metadata_port   => '8775',
  shared_secret   => 'shared_secret',
  zookeeper_hosts => [ { 'ip' => '127.0.0.1' } ],
}
```

Afterwards on every controller/compute, the `midonet_host_registry` custom
type should be used to register the node in MidoNet.

On gateway nodes one should install Midolman (see above) and configure the
uplink:

* Use the `::midonet::gateway::static` class to configure a fake static uplink
* Use the `midonet_gateway_bgp` custom type to configure the BGP uplink

For examples on how to use all the classes see the manifests in the `roles`
folder at `midonet/puppet-midonet_openstack`.


## Implementation

### midonet

midonet is a combination of Puppet manifest and ruby code to deliver
configuration and extra functionality through *types* and *providers*.

### Types

#### midonet_gateway_bgp

The `midonet_gateway_bgp` provider allows to configure a BGP uplink in the
gateway node.

```puppet
midonet_gateway_bgp { 'edge-router':
  ensure                  => present,
  bgp_local_as_number     => '65520',
  bgp_advertised_networks => [ '200.200.0.0/24' ],
  bgp_neighbors           => [
    {
      'ip_address' => '192.168.1.6',
      'remote_asn' => '65506',
      'remote_net' => '192.168.1.0/24'
    }
  ],
  midonet_api_url         => 'http://127.0.0.1:8181',
  username                => 'admin',
  password                => 'safe_password',
  tenant_name             => 'admin',
}
```

##### bgp_local_as_number

The local AS number that this gateway will use.

##### bgp_advertised_networks

An array listing all the floating IP networks that will be advertised.

##### bgp_neighbors

An array of BGP peers. Each on the elements needs to have the following
attributes:

* `ip_address`: IP address of the BGP peer
* `remote_asn`: Remote AS number
* `remote_net`: Network on which the BGP peer is

##### midonet_api_url

URL of the MidoNet API in the format `http://<HOST>:<PORT>`.

##### username

Username for the `admin` user. Defaults to `admin`.

##### password

Password for this user. Defaults to `admin`.

##### tenant_name

Tenant name on which we want to apply the changes. Defaults to `admin`.


#### midonet_host_registry

The `midonet_host_registry` registers a MidoNet node through the MidoNet API. It
is necessary to use this type on every node that runs Midolman.

```puppet
midonet_host_registry { 'myhost':
  ensure              => present,
  midonet_api_url     => 'http://127.0.0.1:8181',
  tunnelzone_name     => 'tzone0'
  tunnelzone_type     => 'gre',
  username            => 'admin',
  password            => 'admin',
  tenant_name         => 'admin',
  underlay_ip_address => $::ipaddress,
}
```

##### midonet_api_url

URL for the MidoNet API in the form of `http://<HOST>:<PORT>`.

##### tunnelzone_name

Name of the tunnel zone where the host will be registered. Defaults to `tzone0`.

##### tunnelzone_type

The type of tunnel zone. Can be set to `gre` or `vxlan`. Defaults to `gre`.

##### username

Username of the `admin` user in Keystone. Defaults to `admin`.

##### password

Password of the `admin` user in Keystone. Defaults to `admin`.

##### tenant_name

Tenant name of the `admin` user. Defaults to `admin`.

##### underlay_ip_address

IP address that will be used to as the underlay layer to create the tunnels.
It will take the fact `$::ipaddress` by default.


#### midonet_client_conf

This type is used to manage the configuration at `/root/.midonetrc`.

```puppet
midonet_client_conf {
  'cli/username': value => 'admin';
}
```

This would set the `username` setting inside the `cli` section to `admin`.

## Limitations

The following platforms are supported:

* Ubuntu 14.04 (Trusty)
* Ubuntu 16.04 (Xenial)
* CentOS 7

The module has been tested in both Puppet versions `3.x` and `4.x`.

Please note that if there is a dedicated analytics node provisioned with
`::midonet::analytics` you will need to place a virtualhost file manually
on the controller for the midonet manager to be able to reach the
analytics endpoints (using `ProxyPass` is enough).


## Beaker-Rspec

This module has beaker-rspec tests

To run:

```shell
bundle install
bundle exec rspec spec/acceptance
```


## Development

The project follows for the most part the OpenStack development model.
Developer documentation for the entire puppet-openstack project is at:

* http://docs.openstack.org/developer/puppet-openstack-guide/

Check out current bugs or open new ones on JIRA project:

    https://midonet.atlassian.net/projects/PUP

Feel free to assign an empty one to yourself!


Contributors
------------
The github [contributor graph](https://github.com/openstack/puppet-midonet/graphs/contributors).
