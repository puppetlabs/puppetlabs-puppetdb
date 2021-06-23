## puppetlabs-puppetdb changelog

Release notes for the puppetlabs-puppetdb module.

#### 7.9.0 - 2021/06/23

* When `manage_database` is true, it will create a read-only user in postgres
  and configure PuppetDB to use that user for its read-database connection
  pool
* Update module dependencies for inifile, firewall, and stdlib

#### 7.8.0 - 2021/03/25

* Added an option `postgresql_ssl_on` to enable an SSL connection between
  PostgreSQL and PuppetDB using Puppet agent certificates to verify the
  connection and authorize PuppetDB to access the puppetdb database.
* Update our metadata to allow puppetlabs-postgresql 7 (this fixes an issue on el8)

#### 7.7.1 - 2020/12/15

* When using Puppet 7 or newer, the connection validator will use the new HTTP
  client. This removes a deprecation warning in the agent output.

#### 7.7.0 - 2020/11/05

* When applied to a node running puppet `7.0.0` or newer, the
  `puppetdb::master::config` class will default to the `json` fact cache. See
  [PUP-10656](https://tickets.puppetlabs.com/browse/PUP-10656) for more
  information.

#### 7.6.0 - 2020/09/02

* Added `migrate` parameter to manage the database.ini config option
* Added Ubuntu 20.04 LTS as a supported platform

#### 7.5.0 - 2020/06/10

* Added `java_bin` parameter to set the full path to the java bin
* Added `node_purge_gc_batch_limit` parameter
* Added `facts_blacklist` parameter to manage the database.ini config option
* Added `manage_db_password` and `manage_read_db_password` parameters
* Updated functions to use puppet4 functions
* Added `enable_storeconfigs` parameter, specifies whether or not the manage the master's storeconfigs (default: `true`)

#### 7.4.0 - 2019/06/14

This is a minor feature release.

Detailed changes:
* Add the `manage_database` parameter to skip database and extension creation

#### 7.3.0 - 2019/06/14

This is a minor feature release.

Detailed changes:
* Update module dependencies for firewall and stdlib

#### 7.2.0 - 2019/05/17

This is a minor feature release.

Detailed changes:
* Update module dependencies for inifile and PostgreSQL

#### 7.1.0 - 2018/10/02

This is a minor feature release.

Detailed changes:
* Fix issue with DLO path default being hardcoded
* Update module dependencies to allow compatibility with Puppet 6

------------------------------------------

#### 7.0.1 - 2018/07/30

This is a minor bugfix release.

Detailed changes:
* Update the upper bound of required puppet version in metadata.json (Thanks @ekohl!)

------------------------------------------

#### 7.0.0 - 2018/06/27

This is a major release that replaces validate_* methods with data types.
The minimum required version of puppetlabs/stdlib has been bummped to 4.13.1
in order to get the new data types. Thanks very much to @bastelfreak for your
submissions!

Detailed changes:
* Require puppetlabs/stdlib >= 4.13.1
* Bump puppet-lint to version 2
* Bump minimal recommended puppet4 version to 4.7.1
* Replace uses of validate_* methods in favor of data types (Thanks @bastelfreak!)
* Add data type for ttl (Thanks @bastelfreak!)
* Update list of supported platforms
* Retire the previously deprecated `database_ssl` and `read_database_ssl` params in favor of `jdbc_ssl_properties` and `read_database_jdbc_ssl_properties`

------------------------------------------

#### 6.0.2 - 2017/11/06

This is a minor bugfix release.

Detailed changes:

 * Update the upper bound of the puppetlabs inifile dependency
 * Explicitly add database dependency in the PostgreSQL manifest (Thanks @pgassmann!)

------------------------------------------

#### 6.0.1 - 2017/06/05

This is a minor bugfix release.

Detailed changes:

* Update the required puppet version in metadata.json

------------------------------------------

#### 6.0.0 - 2017/06/05

This is a major release to support PuppetDB 5.0. Note that the default
PostgreSQL version is now 9.6, the minimum required by PuppetDB 5.0. If you're
running an older version, be sure to explicitly specifying it when upgrading the
module so it doesn't get upgraded out from under you.

Detailed changes:

* Require Puppet >= 4.7
* If unspecified, install PostgreSQL version 9.6
* Default node-ttl and node-purge ttl to 7 days and 14 days, respectively.
* Support puppetlabs-postgresql version 5.x (Thanks @dhollinger!)
* Add create_service_resource param to avoid duplicate resource
  errors in some situations. (Thanks @kpaulisse!)
* Configure the master service as 'enabled' when it is automatically added
  (Thanks @tampakrap!)
* Add concurrent_writes parameter (Thanks @aperiodic!)
* Add cipher_suites option to configure jetty's SSL support (Thanks @selyx!)
* Add support for Ruby 2.3.1 (Thanks @ghoneycutt!)
* Specify mode of routes.yaml (Thanks @tampakrap!)
* Add [read_]database_max_pool_size parameter (Thanks @kpaulisse and @vine77!)
* Fix user/group names on OpenBSD (Thanks @buzzdeee!)
* Enforce permissions of managed ini files (Thanks @kbarber!)
* Manage the pg_trgm database extension (Thanks @PascalBourdier!)
* Default open_ssl_listen_port to undef instead of true (Thanks @mmckinst!)


------------------------------------------

#### 5.1.2 - 2016/03/14

This is a minor bugfix release.

Detailed changes:

* Support RHEL upgrades from the `puppetdb-terminus` (<= PuppetDB 2) to the
`puppetdb-termini` (>= PuppetDB 3).

------------------------------------------

#### 5.1.1 - 2016/02/09

This is a minor bugfix release.

Detailed changes:

* Revert a change to 'puppetdb-terminus' installation process that occurred in
the last release.

------------------------------------------

#### 5.1.0 - 2016/02/09

This is a minor feature release.

Detailed changes:

* Use 'puppetdb-terminus' as the terminus package on RHEL, to avoid packaging
  conflicts that could occur on upgrades from 2.x to 3.x. The
  'puppetdb-terminus' version 3.x package on RHEL will install
  'puppetdb-termini' as a dependency.
* Add jdbc_ssl_properties parameter.
* Pass 'dport' parameter to puppetlabs/firewall instead of the deprecated 'port'.
* Pass database_port parameter to the postgresql class.
* Manage the puppetdb vardir.
* Allow default java_args to be overridden.
* Linting fixes.

------------------------------------------

#### 5.0.0 - 2015/07/08

This is a major release to provide default support for PuppetDB 3.0.0, so
lots of changes have been introduced. Ensure you read the upgrade guide
provided in the README before upgrading to this release.

Detailed changes:

* Packaging paths by default favour the PDB 3.0.0 AIO paths now.
* Added legacy handling for old terminus & service versions (see upgrade guide
  in README for details)
* PDB 3.0.0 introduces new pathing for the API requests, so all the defaults
  for this module are switched to use that now.
* Support for Puppet 4 added.
* manage_pg_repo is now on by default when using the puppetlabs/postgresql module,
  as PDB 3.0.0 supports only 9.4. This enables the use of the upstream PGDG
  PostgreSQL repos for all distros to obtain a working version of 9.4. The
  option can be disabled if required.
* Default ssl-host is now 0.0.0.0

------------------------------------------

#### 4.3.0 - 2015/06/10

This is a minor feature release.

Detailed changes:

* Feature: Provide `database_embedded_path` option for overriding HSQLDB file path.
* Feature: Add ability to manage `command_threads`, `store_usage` and `temp_usage`.
* Bug: allow database_validation to be false
* Bug: Fix ordering issues with read_database_ini
* Testing: Fix file_concat dependency and fix rspec warnings

------------------------------------------

#### 4.2.1 - 2015/04/07

This is a minor bugfix release.

Detailed Changes:

* Ignore `._foo` files when building the `.tar.gz` of the module.

------------------------------------------

#### 4.2.0 - 2015/04/02

This is a minor feature release.

Detailed Changes:

* Added Puppet 4 compatibility by introspecting the value for `$puppet_confdir`.
* Added `masterless` param switch to enable or disable the masterless setup of PuppetDB.
* Added `manage_package_repo` param which will setup the official PostgreSQL repositories on your host.
* Added FreeBSD support.
* The puppetdb service now restarts if the certificates change.
* `manage_firewall` and `ssl_protocols` are now configurable through the top-level puppetdb class.
* Show the puppetdb server URI scheme in connection errors.
* `test_url` param is now properly passed from the resource to the provider.
* Removed dead PE code and unused variables from the module.
* New parameter `puppetdb_disable_ssl` to enable validation to use cleartext.
* Database validation is now optional via the `database_validate` and `read_database_validate` params.
* Documentation updates to the README and metadata.json.

------------------------------------------

#### 4.1.0 - 2014/11/13

This is a minor feature release.

Detailed Changes:

* New capabilities added for installing SSL certificates and keys.
* New parameter `puppetdb_disable_ssl` to enable validation to use cleartext.
* `ssl_protocols` now provided to allow users to fine tune what protocols they want to support for PuppetDB.
* Lots of documentation and parameter cleanups, to ensure consistency.
* test_url is now supported for `puppetdb::master::config` to allow the URL one uses to be overridden.
* Corrected PE detection support.
* Correct the path for HSQLDB to use /var/lib/puppetdb/db instead of /usr/share/puppetdb/db as is standard in PuppetDB core.

------------------------------------------

#### 4.0.0 - 2014/09/16

For this release, all dependency versions have been bumped to their latest.

Detailed Changes:

* The PuppetDB module now only supports Puppet 3.7.1 or later
* 'puppetlabs/postgresql' 4.0.0 or later is now required
* 'puppetlabs/inifile' 1.1.3 or later is now required
* 'puppetlabs/firewall' 1.1.3 or later is now required
* 'puppetlabs/stdlib' 4.2.2 or later is now required
* The parameter `manage_firewall` for the class `puppetdb::database::postgresql` has now been removed, since the postgresql module no longer supports this.
* The parameter `open_postgres_port` for the class `puppetdb` has also been removed, due to postgresql changes.

------------------------------------------

#### 3.0.1 - 2014/02/11

This release contains only minor bug fixes.

Detailed Changes:

* Add missing PUBLISHER_LOGIN variable for auto-publish. (Ashley Penney)
* fix validation regular expressions for time configs (Scott Duckworth)
* update ripienaar/concat -> puppetlabs/concat (Joshua Hoblitt)
* Fix issue with validator when disable_ssl = true (Elliott Barrere)
* Enable soft_write_failure setting when $puppetdb::disablessl = true (Elliott Barrere)
* Support rspec-puppet v1.0.0 (Garrett Honeycutt)
* Pin rspec-puppet to 1.x releases (Ken Barber)
* Define parameter in puppetdb class to define postgres listen address (Adrian Lopez)
* Enable fast finish in Travis (Garrett Honeycutt)
* Convert tests to beaker (Ashley Penney)
* Use the /v2 metrics endpoint instead of /metrics (Ken Barber)

------------------------------------------

#### 3.0.0 - 2013/10/27

This major release changes the main dependency for the postgresql module from
version 2.5.x to 3.x. Since the postgresql module is not backwards compatible,
this release is also not backwards compatible. As a consequence we have taken
some steps to deprecate some of the older functionality:

* The parameter manage_redhat_firewall for the class puppetdb has now been removed completely in favor of open_postgres_port and open_ssl_listen_port.
* The parameter manage_redhat_firewall for the class puppetdb::database::postgresql, has now been renamed to manage_firewall.
* The parameter manage_redhat_firewall for the class puppetdb::server has now been removed completely in favor of open_listen_port and open_ssl_listen_port.
* The internal class: puppetdb::database::postgresql_db has been removed. If you were using this, it is now defunct.
* The class puppetdb::server::firewall has been marked as private, do not use it directly.
* The class puppetdb::server::jetty_ini and puppetdb::server::database_ini have been marked as private, do not use it directly.

All of this is documented in the upgrade portion of the README.

Additionally some features have been included in this release as well:

* soft_write_failure can now be enabled in your puppetdb.conf with this
  module to handle failing silently when your PuppetDB is not available
  during writes.
* There is a new switch to enable SSL connectivity to PostgreSQL. While this
  functionality is only in its infancy this is a good start.

Detailed Changes:

* FM-103: Add metadata.json to all modules. (Ashley Penney)
* Add soft_write_failure to puppetdb.conf (Garrett Honeycutt)
* Add switch to configure database SSL connection (Stefan Dietrich)
* (GH-91) Update to use rspec-system-puppet 2.x (Ken Barber)
* (GH-93) Switch to using puppetlabs-postgresql 3.x (Ken Barber)
* Fix copyright and project notice (Ken Barber)
* Adjust memory for PuppetDB tests to avoid OOM killer (Ken Barber)
* Ensure ntpdate executes early during testing (Ken Barber)

------------------------------------------

#### 2.0.0 - 2013/10/04

This major release changes the main dependency for the inifile module from
the deprecated `cprice404/inifile` to `puppetlabs/inifile` to remove
deprecation warnings and to move onto the latest and greatest implementation
of that code.

Its a major release, because it may affect other dependencies since modules
cannot have overlapping second part dependencies (that is inifile cannot be from
two different locations).

It also adds the parameter `puppetdb_service_status` to the class `puppetdb` to
allow users to specify whether the module manages the puppetdb service for you.

The `database_password` parameter is now optional, and initial Arch Linux
support has been added.

Detailed Changes:

* (GH-73) Switch to puppetlabs/inifile from cprice/inifile (Ken Barber)
* Make database_password an optional parameter (Nick Lewis)
* add archlinux support (Niels Abspoel)
* Added puppetdb service control (Akos Hencz)

------------------------------------------

#### 1.6.0 - 2013/08/07

This minor feature release provides extra parameters for new configuration
items available in PuppetDB 1.4, and also provides some older parameters
that were missed previously:

* gc_interval
* log_slow_statements
* conn_max_age
* conn_keep_alive
* conn_lifetime

Consult the README.md file, or the PuppetDB documentation for more details.

------------------------------------------

#### 1.5.0 - 2013/07/18

This minor feature release provides the following new functionality:

* The module is now capable of managing PuppetDB on SUSE systems
  for which PuppetDB packages are available
* The ruby code for validating the PuppetDB connection now
  supports validating on a non-SSL HTTP port.

------------------------------------------

#### 1.4.0 - 2013/05/13

This feature release provides support for managing the puppetdb report
processor on your master.

To enable the report processor, you can do something like this:

    class { 'puppetdb::master::config':
        manage_report_processor => true,
        enable_reports => true
    }

This will add the 'puppetdb' report processor to the list of `reports`
inside your master's `puppet.conf` file.

------------------------------------------

#### 1.3.0 - 2013/05/13

This feature release provides us with a few new features for the PuppetDB
module.

You can now disable SSL when using the `puppetdb` class by using the new
parameter `disable_ssl`:

    class { 'puppetdb':
      disable_ssl => true,
    }

This will remove the SSL settings from your `jetty.ini` configuration file
disabling any SSL communication. This is useful when you want to offload SSL
to another web server, such as Apache or Nginx.

We have now added an option `java_args` for passing in Java options to
PuppetDB. The format is a hash that is passed in when declaring the use of the
`puppetdb` class:

    class { 'puppetdb':
      java_args => {
        '-Xmx' => '512m',
        '-Xms' => '256m',
      }
    }

Also, the default `report-ttl` was set to `14d` in PuppetDB to align it with an
upcoming PE release, so we've also reflected that default here now.

And finally we've fixed the issue whereby the options `report_ttl`, `node_ttl`,
`node_purge_ttl` and `gc_interval` were not making the correct changes. On top
of that you can now set these values to zero in the module, and the correct
time modifier (`s`, `m`, `h` etc.) will automatically get applied for you.

Behind the scenes we've also added system and unit testing, which was
previously non-existent. This should help us reduce regression going forward.

Thanks to all the contributing developers in the list below that made this
release possible :-).

#### Changes

* Allows for 0 _ttl's without time signifier and enables tests (Garrett Honeycutt)
* Add option to disable SSL in Jetty, including tests and documentation (Christian Berg)
* Cleaned up ghoneycutt's code a tad (Ken Barber)
* the new settings report_ttl, node_ttl and node_purge_ttl were added but they are not working, this fixes it (fsalum)
* Also fix gc_interval (Ken Barber)
* Support for remote puppetdb (Filip Hrbek)
* Added support for Java VM options (Karel Brezina)
* Add initial rspec-system tests and scaffolding (Ken Barber)

------------------------------------------

#### 1.2.1 - 2013/04/08

This is a minor bugfix that solves the PuppetDB startup exception:

    java.lang.AssertionError: Assert failed: (string? s)

This was due to the default `node-ttl` and `node-purge-ttl` settings not having a time suffix by default. These settings required 's', 'm', 'd' etc. to be suffixed, even if they are zero.

#### Changes

* (Ken Barber) Add 's' suffix to period settings to avoid exceptions in PuppetDB

------------------------------------------

#### 1.2.0 - 2013/04/05

This release is primarily about providing full configuration file support in the module for PuppetDB 1.2.0. (The alignment of version is a coincidence I assure you :-).

This feature release adds the following new configuration parameters to the main `puppetdb` class:

* node_ttl
* node_purge_ttl (available in >=1.2.0)
* report_ttl

Consult the README for futher details about these new configurable items.

##### Changes

* (Nick Lewis) Add params and ini settings for node/purge/report ttls and document them

------------------------------------------

1.1.5
=====

2013-02-13 - Karel Brezina
 * Fix database creation so database_username, database_password and
   database_name are correctly passed during database creation.

2013-01-29 - Lauren Rother
 * Change README to conform to new style and various other README improvements

2013-01-17 - Chris Price
 * Improve documentation in init.pp

------------------------------------------

1.1.4
=====

This is a bugfix release, mostly around fixing backward-compatibility for the
deprecated `manage_redhat_firewall` parameter.  It wasn't actually entirely
backwards-compatible in the 1.1.3 release.

2013-01-17 - Chris Price <chris@puppetlabs.com>
 * Fix backward compatibility of `manage_redhat_firewall` parameter (de20b44)

2013-01-16 - Chris Price <chris@puppetlabs.com>
 * Fix deprecation warnings around manage_redhat_firewall (448f8bc)

------------------------------------------

1.1.3
=====

This is mostly a maintenance release, to update the module dependencies to newer
versions in preparation for some new features.  This release does include some nice
additions around the ability to set the listen address for the HTTP port on Jetty
and manage the firewall for that port.  Thanks very much to Drew Blessing for those
submissions!

2013-01-15 - Chris Price <chris@puppetlabs.com>
 * Update Modulefile for 1.1.3 release (updates dependencies
   on postgres and inifile modules to the latest versions) (76bfd9e)

2012-12-19 - Garrett Honeycutt <garrett@puppetlabs.com>
 * (#18228) updates README for style (fd2e990)

2012-11-29 - Drew Blessing <Drew.Blessing@Buckle.com>
 * 17594 - Fixes suggested by cprice-puppet (0cf9632)

2012-11-14 - Drew Blessing <Drew.Blessing@Buckle.com>
 * Adjust examples in tests to include new port params (0afc276)

2012-11-13 - Drew Blessing <Drew.Blessing@Buckle.com>
 * 17594 - PuppetDB - Add ability to set standard host listen address and open firewall

------------------------------------------

1.1.2
=====

2012-10-26 - Chris Price <chris@puppetlabs.com> (1.1.2)
 * 1.1.2 release

2012-10-26 - Chris Price <chris@puppetlabs.com>
 * Add some more missing `inherit`s for `puppetdb::params` (a72cc7c)

2012-10-26 - Chris Price <chris@puppetlabs.com> (1.1.2)
 * 1.1.1 release

2012-10-26 - Chris Price <chris@puppetlabs.com> (1.1.1)
 * Add missing `inherit` for `puppetdb::params` (ea9b379)

2012-10-24 - Chris Price <chris@puppetlabs.com>
 * 1.1.0 release

2012-10-24 - Chris Price <chris@puppetlabs.com> (1.1.0)
 * Update postgres dependency to puppetlabs/postgresql (bea79b4)

2012-10-17 - Reid Vandewiele <reid@puppetlabs.com> (1.1.0)
 * Fix embedded db setup in Puppet Enterprise (bf0ab45)

2012-10-17 - Chris Price <chris@puppetlabs.com> (1.1.0)
 * Update manifests/master/config.pp (b119a30)

2012-10-16 - Chris Price <chris@puppetlabs.com> (1.1.0)
 * Make puppetdb startup timeout configurable (783b595)

2012-10-01 - Hunter Haugen <h.haugen@gmail.com> (1.1.0)
 * Add condition to detect PE installations and provide different parameters (63f1c52)

2012-10-01 - Hunter Haugen <h.haugen@gmail.com> (1.1.0)
 * Add example manifest code for pe puppet master (a598edc)

2012-10-01 - Chris Price <chris@puppetlabs.com> (1.1.0)
 * Update comments and docs w/rt PE params (b5df5d9)

2012-10-01 - Hunter Haugen <h.haugen@gmail.com> (1.1.0)
 * Adding pe_puppetdb tests class (850e039)

2012-09-28 - Hunter Haugen <h.haugen@gmail.com> (1.1.0)
 * Add parameters to enable usage of enterprise versions of PuppetDB (df6f7cc)

2012-09-23 - Chris Price <chris@puppetlabs.com>
 * 1.0.3 release

2012-09-23 - Chris Price <chris@puppetlabs.com>
 * Add a parameter for restarting puppet master (179b337)

2012-09-21 - Chris Price <chris@puppetlabs.com>
 * 1.0.2 release

2012-09-21 - Chris Price <chris@puppetlabs.com>
 * Pass 'manage_redhat_firewall' param through to postgres (f21740b)

2012-09-20 - Chris Price <chris@puppetlabs.com>
 * 1.0.1 release

2012-09-20 - Garrett Honeycutt <garrett@puppetlabs.com>
 * complies with style guide (1aab5d9)

2012-09-19 - Chris Price <chris@puppetlabs.com>
 * Fix invalid subname in database.ini (be683b7)

2011-09-18 Chris Price <chris@puppetlabs.com> - 1.0.0
* Initial 1.0.0 release
