puppetdb
=========

Module Description
-------------------

PuppetDB is Puppet's next-generation, open source "data warehouse" service for managing 
storage and retrieval of all platform-generated data. As a centralized store, PuppetDB 
knows about every node, resource, relationship, and fact across your entire infrastructure.
This knowledge allows PuppetDB to make a few promises about its data: data will be 
complete, it will be accurate, and it will be current. The module makes this information 
easily queryable, so you can  integrate it into your tools and workflow or just satisfy 
your curiosity. 

With PuppetDB, you install and manage the puppetdb server and database. Whether you just 
want to throw it onto a test system as quickly as possible so that you can check its 
features out, or you want finer-grained access to manage the individual settings and 
configuration, PuppetDB aims to let you dive in at the exact level of involvement that you
desire.

PuppetDB comes with a built-in dashboard, which uses the HTTP metrics API to give you an 
overview of the current state of your system. The dashboard updates live, even on your 
mobile device! It allows you to see the backlog of work, how long command processing is 
taking, how much work has been done, how large the database is, and much more. 

Getting Started
----------------

Once you have installed PuppetDB, there are a few decisions you’ll have to make:

* Which database back-end should I use? (The current choices are PostgreSQL or our 
embedded database; we’ll discuss this more a bit later on.)
* Should I run the database on the same node that I run PuppetDB on?
* Should I run PuppetDB on the same node that I run my master on?

The answers to those questions will be largely dependent on your Puppet environment
 
* How many nodes are you managing? 
* What kind of hardware are you running on? 
* Is your current load approaching the limits of your hardware?

Depending on your answers to the questions above, you will likely fall under one of these 
set-up options:

1. The Simple Case
2. A Distributed Setup

### The Simple Case

This approach assumes you will use our default database (PostgreSQL) and run everything 
(PostgreSQL, PuppetDB, puppet master) all on the same node. This setup will be great for a
testing or experimental environment, and may be sufficient for many real-world deployments
depending on the number of nodes you’re managing. In this case, your manifest will look 
like:
	
	node puppetmaster {
   	  # Configure puppetdb and its underlying database
   	  include puppetdb
   	  # Configure the puppet master to use puppetdb
   	  include puppetdb::master::config
	}

You can provide some parameters for these classes if you’d like more control, but that is
literally all that it will take to get you up and running with the default configuration. 
This manifest will cause: PostgreSQL to install on the node if it’s not already there; 
PuppetDB postgres database instance and user account to be created; the postgres 
connection to be validated and, if successful, PuppetDB to be installed and
configured; PuppetDB connection to be validated and, if successful, the puppet master 
config files to be modified to use PuppetDB; and the puppet master to be restarted so that
it will pick up the config changes.

If your logging level is set to INFO or finer, you should start seeing PuppetDB-related 
log messages appear in both your puppet master log and your puppetdb log as subsequent 
agent runs occur.

If you’d prefer to use PuppetDB’s embedded database rather than PostgreSQL, have a 
look at the database parameter on the puppetdb class. 
	
	class puppetdb::params {
	  ...
	  $database                  = 'postgres'
	# The remaining database settings are not used for an embedded database
  	  $database_host          = 'localhost'
  	  $database_port          = '5432'
  	  $database_name          = 'puppetdb'
  	  $database_username      = 'puppetdb'
  	  $database_password      = 'puppetdb'
  	  ...
  	}
  	  
The embedded database can be useful for testing and very small production environments, 
but it is not recommended for production environments since it consumes a great deal of 
memory as your number of nodes increase.

### A Distributed Setup

This approach is for those who prefer not to install PuppetDB on the same node as the 
puppet master. Your environment will be easier to scale if you are able to dedicate 
hardware to the individual system components. You may even choose to run the puppetdb 
server on a different node from the PostgreSQL database that it uses to store its data. 
So let’s have a look at what a manifest for that scenario might look like:

**This is an example of a very basic 3-node setup for PuppetDB.**

This node is our puppet master:

	node puppet {
      # Here we configure the puppet master to use PuppetDB,
      # and tell it that the hostname is ‘puppetdb’
      class { 'puppetdb::master::config':
          puppetdb_server => 'puppetdb',
      }
	}

This node is our postgres server:

	node puppetdb-postgres {
      # Here we install and configure postgres and the puppetdb
      # database instance, and tell postgres that it should
      # listen for connections to the hostname ‘puppetdb-postgres’
      class { 'puppetdb::database::postgresql':
          listen_addresses => 'puppetdb-postgres',
      }
	}

This node is our main puppetdb server:

	node puppetdb {
      # Here we install and configure PuppetDB, and tell it where to
      # find the postgres database.
      class { 'puppetdb::server':
          database_host      => 'puppetdb-postgres',
      }
	}
	
This should be all it takes to get a 3-node, distributed installation of PuppetDB up and 
running. Note that, if you prefer, you could easily move two of these classes to a single 
node and end up with a 2-node setup instead.

### Cross-node Dependencies

At this point, you may have spotted some cross-node dependencies, and you’ve probably 
recognized that the order in which these nodes check in with the puppet master will have 
serious implications for getting everything up and running. It would be very bad to 
configure the master to use the puppetdb server before that server was up and running. 
Likewise, it wouldn’t be great to try to start up the puppetdb server pointing to a 
postgres server that isn’t actually running Postgres yet.

The module handles this problem for you by taking a sort of “eventual consistency” 
approach. There’s nothing that the module can do to control the order in which your nodes
check in, but the module can check to verify that the services it depends on are up and 
running before it makes configuration changes--so that’s what it does.

When your puppet master node checks in, it will validate the connectivity to the puppetdb 
server before it applies its changes to the puppet master config files. If it can’t 
connect to puppetdb, then the puppet run will fail and the previous config files will be 
left intact. This prevents your master from getting into a broken state where all incoming
puppet runs fail because the master is configured to use a puppetdb server that doesn’t 
exist yet. The same strategy is used to handle the dependency between the puppetdb server
and the postgres server.

This means that the first time you add the module's configurations to your manifests, you 
may see a few failed puppet runs on the affected nodes. This should be limited to 1 failed
run on the puppetdb node, and up to 2 failed runs on the puppet master node. After that, 
all of the dependencies should be satisfied and your puppet runs should start to succeed 
again.

You can also manually trigger puppet runs on the nodes in the correct order (Postgres, 
PuppetDB, puppet master), which will avoid any failed runs.

Usage
------

PuppetDB supports a large number of configuration options for both configuring the 
puppetdb service and connecting that service to the puppet master.

The **puppetdb** class is intended as a high-level abstraction (sort of an 'all-in-one' 
class) to help simplify the process of getting your puppetdb server up and running. It 
wraps the slightly-lower-level classes `puppetdb::server` and `puppetdb::database::*`, 
and it'll get you up and running with everything you need (including database setup and 
management) on the server side.  For maximum configurability, you may choose not to use 
this class.  You may prefer to use the `puppetdb::server` class directly, or manage your 
puppetdb setup on your own. 

You must declare the class to use it:

	include puppetdb

Within puppetdb, you will find the following variables to configure to your environment:

>**`listen_address`**

>The address that the web server should bind to for HTTP requests (defaults to `localhost`.
>'0.0.0.0' = all).

>**`listen_port`**

>The port on which the puppetdb web server should accept HTTP requests (defaults to 8080).

>**`open_listen_port`**

>If true, open the http listen port on the firewall (defaults to false).

>**`ssl_listen_address`**

>The address that the web server should bind to for HTTPS requests (defaults to 
`$::clientcert`). Set to '0.0.0.0' to listen on all addresses.

>**`ssl_listen_port`**

>The port on which the puppetdb web server should accept HTTPS requests (defaults to 8081).

>**`open_ssl_listen_port`**

>If true, open the ssl listen port on the firewall (defaults to true).

>**`database`**

>Which database backend to use; legal values are `postgres` (default) or `embedded`. The 
`embedded` db can be used for very small installations or for testing, but is not 
recommended for use in production environments. For more info, see the [puppetdb docs](http://docs.puppetlabs.com/puppetdb/).

>**`database_port`**

>The port that the database server listens on (defaults to `5432`; ignored for `embedded` 
db).

>**`database_username`**

>The name of the database user to connect as (defaults to `puppetdb`; ignored for 
`embedded` db).

>**`database_password`**

>The password for the database user (defaults to `puppetdb`; ignored for `embedded` db).

>**`database_name`**

>The name of the database instance to connect to (defaults to `puppetdb`; ignored for 
`embedded` db).

>**`database_package`**

>The puppetdb package name in the package manager.

>**`puppetdb_version`**

>The version of the `puppetdb` package that should be installed.  You may specify an 
explicit version number, 'present', or 'latest' (defaults to 'present').

>**`puppetdb_service`**

>The name of the puppetdb service.

>**`manage_redhat_firewall`**
 
>*DEPRECATED: Use open_ssl_listen_port instead.*

>Supports a Boolean of true or false, indicating whether or not the module should open a 
port in the firewall on redhat-based systems.  Defaults to `false`.  This parameter is 
likely to change in future versions. Possible changes include support for non-RedHat 
systems and finer-grained control over the firewall rule (currently, it simply opens up 
the postgres port to all TCP connections).

>**`confdir`**

>The puppetdb configuration directory (defaults to `/etc/puppetdb/conf.d`).

The **puppetdb::server** class manages the puppetdb server independently of the underlying
database that it depends on. It will manage the PuppetDB package, service, config files, 
etc., but will still allow you to manage the database (e.g. postgresql) however you see
fit. 

	class { 'puppetdb::server':
      database_host     	   => 'puppetdb-postgres',
     }

`puppetdb::server` has the same parameters as `puppetdb` with one addition: 

>**`database_host`**

>The hostname or IP address of the database server (defaults to `localhost`; ignored for 
`embedded` db).


The **puppetdb::master::config** class directs your puppet master to use PuppetDB, which 
means that this class should be used on your puppet master node. It’ll verify that it can 
successfully communicate with your puppetdb server, and then configure your master to use 
PuppetDB.

Using this class involves allowing the module to manipulate your puppet configuration 
files; in particular: puppet.conf and routes.yaml. The puppet.conf changes are 
supplemental and should not affect any of your existing settings, but the routes.yaml 
file will be overwritten entirely. If you have an existing routes.yaml file, you will 
want to take care to use the manage_routes parameter of this class to prevent the module 
from managing that file, and you’ll need to manage it yourself.

	class { 'puppetdb::master::config':
      puppetdb_server          => 'my.host.name',
	  puppetdb_port            => 8081,
	}

Within `puppetdb::master::config`, you will find the following variables to configure to 
your environment: 

>**`puppetdb_server`**

>The dns name or ip of the puppetdb server (defaults to the certname of the current node).

>**`puppetdb_port`**

>The port that the puppetdb server is running on (defaults to 8081).

>**`manage_routes`**
 
>If true, the module will overwrite the puppet master's routes file to configure it to 
 use puppetdb (defaults to true).
 
>**`manage_storeconfigs`**

>If true, the module will manage the puppet master's storeconfig settings (defaults to 
true).

>**`puppet_confdir`**

>Puppet's config directory (defaults to `/etc/puppet`).

>**`puppet_conf`**

>Puppet's config file (defaults to `/etc/puppet/puppet.conf`).

>**`puppetdb_version`**

>The version of the `puppetdb` package that should be installed.  You may specify an 
explicit version number, 'present', or 'latest' (defaults to 'present').

>**`puppetdb_startup_timeout`**

>The maximum amount of time that the module should wait for puppetdb to start up. This is
most important during the initial install of puppetdb (defaults to 15 seconds).

>**`restart_puppet`**

>If true, the module will restart the puppet master when necessary.  The default is 
'true'.  If set to 'false', you must restart the service manually in order to pick up 
changes to the config files (other than `puppet.conf`). 

The **puppetdb::database::postgresql** class manages a postgresql server for use by
PuppetDB. It can manage the postgresql packages and service, as well as creating and 
managing the puppetdb database and database user accounts.

	class { 'puppetdb::database::postgresql':
      listen_addresses         => 'my.postgres.host.name',
	}

The `listen_address` is a comma-separated list of hostnames or IP addresses on which the 
postgres server should listen for incoming connections. This defaults to `localhost`. 
This parameter maps directly to postgresql's `listen_addresses` config option; use a '*' 
to allow connections on any accessible address.

Implementation
---------------

### Resource overview

In addition to the classes and variables mentioned above, PuppetDB includes:

>**puppetdb::master::routes**

>Configures the puppet master to use PuppetDB as the facts terminus. *WARNING*: the 
current implementation simply overwrites your routes.yaml file; if you have an existing 
routes.yaml file that you are using for other purposes, you should *not* use this.

	class { 'puppetdb::master::routes':
	  puppet_confdir => '/etc/puppet'
	}

>**puppetdb::master::storeconfigs**

>Configures the puppet master to enable storeconfigs and to use PuppetDB as the 
storeconfigs backend.

	class { 'puppetdb::master::storeconfigs':
      puppet_conf => '/etc/puppet/puppet.conf'
	}

>**puppetdb::server::database_ini**

>Manages PuppetDB's `database.ini` file.

	class { 'puppetdb::server::database_ini':
      database_host     => 'my.postgres.host',
      database_port     => '5432',
      database_username => 'puppetdb_pguser',
      database_password => 'puppetdb_pgpasswd',
      database_name     => 'puppetdb',
	}

>**puppetdb::server::validate_db**

> This type validates that a successful database connection can be established between 
the node on which this resource is run and the specified puppetdb database instance 
(host/port/user/password/database name).

	puppetdb::server::validate_db { 'validate my puppetdb database connection':
      database_host           => 'my.postgres.host',
      database_username       => 'mydbuser',
      database_password       => 'mydbpassword',
      database_name           => 'mydbname',
    }

### Custom Types

**puppetdb_conn_validator**

Verifies that a connection can be successfully established between a node and the puppetdb
server. Its primary use is as a precondition to prevent configuration changes from being 
applied if the puppetdb server cannot be reached, but it could potentially be used for 
other purposes such as monitoring.

Limitations
------------

Currently, PuppetDB is compatible with: 
>Puppet Version:	2.7+
>Platforms: RHEL6, Debian6, Ubuntu 10.04

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions
are essential for keeping them great. We can’t access the huge number of platforms and
myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work
in your environment. There are a few guidelines that we need contributors to follow so
that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Disclaimer
-----------



Release Notes
--------------

Minor bugfix release (fix a missing dependency in puppetdb::master::* classes).