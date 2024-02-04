puppetdb
=========

#### Table of Contents

1. [Overview - What is the PuppetDB module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with PuppetDB module](#setup)
4. [Upgrading - Guide for upgrading from older revisions of this module](#upgrading)
4. [Usage - The classes and parameters available for configuration](#usage)
5. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

By guiding puppetdb setup and configuration with a Puppet master, the PuppetDB
module provides fast, streamlined access to data on puppetized infrastructure.

Module Description
-------------------

The PuppetDB module provides a quick way to get started using PuppetDB, an open
source inventory resource service that manages storage and retrieval of
platform-generated data. The module will install PostgreSQL and PuppetDB if you
don't have them, as well as set up the connection to Puppet master. The module
will also provide a dashboard you can use to view the current state of your
system.

For more information about PuppetDB
[please see the official PuppetDB documentation.](https://puppet.com/docs/puppetdb/latest/)


Setup
-----

**What PuppetDB affects:**

* package/service/configuration files for PuppetDB
* package/service/configuration files for PostgreSQL (optional, but set as default)
* Puppet master's runtime (via plugins)
* Puppet master's configuration
  * **note**: Using the `puppetdb::master::config` class will cause your
    routes.yaml file to be overwritten entirely (see **Usage** below for options
    and more information )
* system firewall (optional)
* listened-to ports

**Introductory Questions**

To begin using PuppetDB, you’ll have to make a few decisions:

* Should I run the database on the same node that I run PuppetDB on?
* Should I run PuppetDB on the same node that I run my master on?

The answers to those questions will be largely dependent on your answers to
questions about your Puppet environment:

* How many nodes are you managing?
* What kind of hardware are you running on?
* Is your current load approaching the limits of your hardware?

Depending on your answers to all of the questions above, you will likely fall
under one of these set-up options:

1. [Single Node (Testing and Development)](#single-node-setup)
2. [Multiple Node (Recommended)](#multiple-node-setup)

### Single Node Setup

This approach assumes you will use our default database (PostgreSQL) and run
everything (PostgreSQL, PuppetDB, Puppet master) all on the same node. This
setup will be great for a testing or experimental environment. In this case,
your manifest will look like:

    node <hostname> {
      # Configure puppetdb and its underlying database
      class { 'puppetdb': }
      
      # Configure the Puppet master to use puppetdb
      class { 'puppetdb::master::config': }
    }

You can provide some parameters for these classes if you’d like more control,
but that is literally all that it will take to get you up and running with the
default configuration.

### Multiple Node Setup

This approach is for those who prefer not to install PuppetDB on the same node
as the Puppet master. Your environment will be easier to scale if you are able
to dedicate hardware to the individual system components. You may even choose to
run the puppetdb server on a different node from the PostgreSQL database that it
uses to store its data. So let’s have a look at what a manifest for that
scenario might look like:

**This is an example of a very basic 3-node setup for PuppetDB.**

    $puppetdb_host = 'puppetdb.example.lan'
    $postgres_host = 'postgres.example.lan'
    node 'master.example.lan' {
      # Here we configure the Puppet master to use PuppetDB,
      # telling it the hostname of the PuppetDB node
      class { 'puppetdb::master::config':
        puppetdb_server => $puppetdb_host,
      }
    }
    node 'postgres.example.lan' {
      # Here we install and configure PostgreSQL and the PuppetDB
      # database instance, and tell PostgreSQL that it should
      # listen for connections to the `$postgres_host`
      class { 'puppetdb::database::postgresql':
        listen_addresses => $postgres_host,
      }
    }
    node 'puppetdb.example.lan' {
      # Here we install and configure PuppetDB, and tell it where to
      # find the PostgreSQL database.
      class { 'puppetdb::server':
        database_host => $postgres_host,
      }
    }

This should be all it takes to get a 3-node, distributed installation of
PuppetDB up and running. Note that, if you prefer, you could easily move two of
these classes to a single node and end up with a 2-node setup instead.

### Enable SSL connections

To use SSL connections for the single node setup, use the following manifest:

    node <hostname> {
      # Here we configure puppetdb and PostgreSQL to use ssl connections
      class { 'puppetdb':
        postgresql_ssl_on => true,
        database_host => '<hostname>',
        database_listen_address => '0.0.0.0'
      }
      
      # Configure the Puppet master to use puppetdb
      class { 'puppetdb::master::config': }

To use SSL connections for the multiple nodes setup, use the following manifest:

    $puppetdb_host = 'puppetdb.example.lan'
    $postgres_host = 'postgres.example.lan'

    node 'master.example.lan' {
      # Here we configure the Puppet master to use PuppetDB,
      # telling it the hostname of the PuppetDB node.
      class { 'puppetdb::master::config':
        puppetdb_server => $puppetdb_host,
      }
    }

    node 'postgres.example.lan' {
      # Here we install and configure PostgreSQL and the PuppetDB
      # database instance, and tell PostgreSQL that it should
      # listen for connections to the `$postgres_host`. 
      # We also enable SSL connections.
      class { 'puppetdb::database::postgresql':
        listen_addresses => $postgres_host,
        postgresql_ssl_on => true,
        puppetdb_server => $puppetdb_host
      }
    }

    node 'puppetdb.example.lan' {
      # Here we install and configure PuppetDB, and tell it where to
      # find the PostgreSQL database. We also enable SSL connections.
      class { 'puppetdb::server':
        database_host => $postgres_host,
        postgresql_ssl_on => true
      }
    }

### Beginning with PuppetDB

Whether you choose a single node development setup or a multi-node setup, a
basic setup of PuppetDB will cause: PostgreSQL to install on the node if it’s
not already there; PuppetDB postgres database instance and user account to be
created; the postgres connection to be validated and, if successful, PuppetDB to
be installed and configured; PuppetDB connection to be validated and, if
successful, the Puppet master config files to be modified to use PuppetDB; and
the Puppet master to be restarted so that it will pick up the config changes.

If your logging level is set to INFO or finer, you should start seeing
PuppetDB-related log messages appear in both your Puppet master log and your
puppetdb log as subsequent agent runs occur.

### Cross-node Dependencies

It is worth noting that there are some cross-node dependencies, which means that
the first time you add the module's configurations to your manifests, you may
see a few failed puppet runs on the affected nodes.

PuppetDB handles cross-node dependencies by taking a sort of "eventual
consistency" approach. There’s nothing that the module can do to control the
order in which your nodes check in, but the module can check to verify that the
services it depends on are up and running before it makes configuration
changes--so that’s what it does.

When your Puppet master node checks in, it will validate the connectivity to the
puppetdb server before it applies its changes to the Puppet master config files.
If it can’t connect to puppetdb, then the puppet run will fail and the previous
config files will be left intact. This prevents your master from getting into a
broken state where all incoming puppet runs fail because the master is
configured to use a puppetdb server that doesn’t exist yet. The same strategy is
used to handle the dependency between the puppetdb server and the postgres
server.

Hence the failed puppet runs. These failures should be limited to 1 failed run
on the puppetdb node, and up to 2 failed runs on the Puppet master node. After
that, all of the dependencies should be satisfied and your puppet runs should
start to succeed again.

You can also manually trigger puppet runs on the nodes in the correct order
(Postgres, PuppetDB, Puppet master), which will avoid any failed runs.

Upgrading
---------

### Upgrading from 4.x to 5.x

Significant parameter changes are listed below:

* The PuppetDB module defaults to Puppet 4 pathing and assumes `puppetserver`
  is the master service by default
* The PuppetDB module manages Postgres repos by default. To turn this behavior
  off, set `manage_package_repo` to `false`.
* To specify a specific version of PuppetDB to manage, you'll need to use the
  `puppetdb::globals` class to set the version of PuppetDB you're using
  explicitly. The ability to configure the version in the `puppetdb::server` and
  `puppetdb` class have been removed.

For example if your config looked like this before:

    class {'puppetdb':
        puppetdb_version => '3.2.4-1.el7',
    }
    class { 'puppetdb::master::config': }

and you'd still like to use the module with PuppetDB 3.2.4, all you'd have to
change would be:

    class { 'puppetdb::globals':
        version => '3.2.4-1.el7',
    }
    class { 'puppetdb' : }
    class { 'puppetdb::master::config' : }

The `globals` class above takes into account the following PuppetDB 3 and Puppet
4 related changes:
    * The `puppetdb::master:puppetdb_conf` class has added a `$legacy_terminus`
      to support the PuppetDB 2.x terminus configuration.
    * The default `test_url` for the `PuppetDBConnValidator` has also been
      changed to `/pdb/meta/v1/version` but will default to `/v3/version` when
      using a PuppetDB 2.x version.
    * The configuration pathing for Puppet and PuppetDB has changed with Puppet
      4 and PuppetDB 3, using PuppetDB 2.x or older assumes the old
      configuration pathing.

See the CHANGELOG file for more detailed information on changes for each release.

### Upgrading from 3.x to 4.x

For this release, all dependency versions have been bumped to their latest.
Significant parameter changes are listed below:

* The PuppetDB module now only supports Puppet 3.7.1 or later
* `puppetlabs/postgresql` 4.0.0 or later is now required
* `puppetlabs/inifile` 1.1.3 or later is now required
* `puppetlabs/firewall` 1.1.3 or later is now required
* `puppetlabs/stdlib` 4.2.2 or later is now required
* The parameter `manage_firewall` for the class `puppetdb::database::postgresql`
  has now been removed, since the PostgreSQL module no longer supports this.
* The parameter `open_postgres_port` for the class `puppetdb` has also been
  removed, due to PostgreSQL changes.

See the CHANGELOG file for more detailed information on changes for each release.

### Upgrading from 2.x to 3.x

For this release a major dependency has changed. The module
`pupppetlabs/postgresql` must now be version 3.x. Upgrading the module should
upgrade the `puppetlabs/postgresql` module for you, but if another module has a
fixed dependency that module will have to be fixed before you can continue.

Some other changes include:

* The parameter `manage_redhat_firewall` for the class `puppetdb` has now been
  removed completely in favor of `open_postgres_port` and
  `open_ssl_listen_port`.
* The parameter `manage_redhat_firewall` for the class
  `puppetdb::database::postgresql`, has now been renamed to `manage_firewall`.
* The parameter `manage_redhat_firewall` for the class `puppetdb::server` has
  now been removed completely in favor of `open_listen_port` and
  `open_ssl_listen_port`.
* The internal class: `puppetdb::database::postgresql_db` has been removed. If
  you were using this, it is now defunct.
* The class `puppetdb::server::firewall` has been marked as private, do not use
  it directly.
* The class `puppetdb::server::jetty_ini` and `puppetdb::server::database_ini`
  have been marked as private, do not use it directly.

### Upgrading from 1.x to 2.x

A major dependency has been changed, so now when you upgrade to 2.0 the
dependency `cprice404/inifile` has been replaced with `puppetlabs/inifile`. This
may interfere with other modules as they may depend on the old
`cprice404/inifile` instead, so upgrading should be done with caution. Check
that your other modules use the newer `puppetlabs/inifile` module as
interoperation with the old `cprice404/inifile` module will no longer be
supported by this module.

Depending on how you install your modules, changing the dependency may require
manual intervention. Double check your modules contain the newer
`puppetlabs/inifile` after installing this latest module.

Otherwise, all existing parameters from 1.x should still work correctly.

Usage
------

PuppetDB supports a large number of configuration options for both configuring
the puppetdb service and connecting that service to the Puppet master.

### puppetdb::globals

The `puppetdb::globals` class is intended to provide similar functionality to
the `postgresql::globals` class in the `puppetlabs-postgresql` module by
exposing a top-level entry-point into the module so that we can properly set
defaults for the `puppetdb::params` class based on the version of `puppetdb` you
are using. This setting defaults to `present`.

You must declare the class to use it:

    class { 'puppetdb::globals': }

### puppetdb

The `puppetdb` class is intended as a high-level abstraction (sort of an
'all-in-one' class) to help simplify the process of getting your puppetdb server
up and running. It wraps the slightly-lower-level classes `puppetdb::server` and
`puppetdb::database::*`, and it'll get you up and running with everything you
need (including database setup and management) on the server side. For maximum
configurability, you may choose not to use this class. You may prefer to use the
`puppetdb::server` class directly, or manage your puppetdb setup on your own.

You must declare the class to use it:

    class { 'puppetdb': }

### puppetdb::server

The `puppetdb::server` class manages the PuppetDB server independently of the
underlying database that it depends on. It will manage the PuppetDB package,
service, config files, etc., but will still allow you to manage the database
(e.g. PostgreSQL) however you see fit.

    class { 'puppetdb::server':
      database_host => 'pg1.mydomain.com',
    }

### puppetdb::master::config

The `puppetdb::master::config` class directs your Puppet master to use PuppetDB,
which means that this class should be used on your Puppet master node. It’ll
verify that it can successfully communicate with your PuppetDB server, and then
configure your master to use PuppetDB.

Using this class allows the module to manipulate the puppet configuration files
puppet.conf and routes.yaml. The puppet.conf changes are supplemental and should
not affect any of your existing settings, but the routes.yaml file will be
overwritten entirely. If you have an existing routes.yaml file, you will want to
take care to use the `manage_routes` parameter of this class to prevent the module
from managing that file, and you’ll need to manage it yourself.

    class { 'puppetdb::master::config':
      puppetdb_server => 'my.host.name',
      puppetdb_port   => 8081,
    }

### puppetdb::database::postgresql

The `puppetdb::database::postgresql` class manages a PostgreSQL server for use
by PuppetDB. It can manage the PostgreSQL packages and service, as well as
creating and managing the PuppetDB database and database user accounts.

    class { 'puppetdb::database::postgresql':
      listen_addresses => 'my.postgres.host.name',
    }

Implementation
---------------

### Resource overview

In addition to the classes and variables mentioned above, PuppetDB includes:

**puppetdb::master::routes**

Configures the Puppet master to use PuppetDB as the facts terminus. *WARNING*:
the current implementation simply overwrites your routes.yaml file; if you have
an existing routes.yaml file that you are using for other purposes, you should
*not* use this.

    class { 'puppetdb::master::routes':
      puppet_confdir => '/etc/puppet'
    }

The optional parameter routes can be used to specify a custom route
configuration. For example to configure routes for masterless puppet.

    class { 'puppetdb::master::routes':
      routes => {
        'apply' => {
          'facts' => {
            'terminus' => 'facter',
            'cache'    => 'puppetdb_apply',
          }
        }
      }
    }

**puppetdb::master::storeconfigs**

Configures the Puppet master to enable storeconfigs and to use PuppetDB as the
storeconfigs backend.

    class { 'puppetdb::master::storeconfigs':
      puppet_conf => '/etc/puppet/puppet.conf'
    }

**puppetdb::server::validate_db**

Validates that a successful database connection can be established between the
node on which this resource is run and the specified PuppetDB database instance
(host/port/user/password/database name).

    puppetdb::server::validate_db { 'validate my puppetdb database connection':
      database_host     => 'my.postgres.host',
      database_username => 'mydbuser',
      database_password => 'mydbpassword',
      database_name     => 'mydbname',
    }

### Custom Types

**puppetdb_conn_validator**

Verifies that a connection can be successfully established between a node and
the PuppetDB server. Its primary use is as a precondition to prevent
configuration changes from being applied if the PuppetDB server cannot be
reached, but it could potentially be used for other purposes such as monitoring.

Limitations
------------

Currently, PuppetDB is compatible with:

    Puppet Version: 4.10+

Platforms:
* EL 5, 6, 7
* Debian 6, 7
* Ubuntu 10.04, 12.04, 14.04

Community Maintained Platforms:
* Archlinux
* OpenBSD 5.6-current and newer
* SLES 11 SP1

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community
contributions are essential for keeping them great. We can’t access the huge
number of platforms and myriad of hardware, software, and deployment
configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules
work in your environment. There are a few guidelines that we need contributors
to follow so that we can have a chance of keeping on top of things.

You can read the complete [contribution guide](https://github.com/puppetlabs/.github/blob/master/CONTRIBUTING.md).
