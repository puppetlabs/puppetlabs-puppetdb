puppetlabs-puppetdb
===================

A puppet module for installing and managing puppetdb

This is a work in progress;  currently supports a very limited
setup for single-node (everything on the puppet master machine)
 installation using either hsql or postgres.

 This module depends on the following other puppet modules:

 * puppetlabs-firewall (from the forge)
 * puppetlabs-stdlib (a new version that hasn't been published to the forge
    yet; relies on a commit made on June 10, 2012 (pull req #75)
 * inkling/puppetlabs-postgres (relies on commits made on June 14, 2012,
    in this fork/branch:

     https://github.com/cprice-puppet/puppet-postgresql/tree/feature/master/align-with-puppetlabs-mysql

Hopefully after a bit more polish, all of these will be published to the forge.