# NOTE!! This manifest will set everything up *except* for your
#  puppet.conf file;  to that, you'll need to manually add the following
#  lines to the 'main' section:
#
#     server=<your certname here>
#     storeconfigs=true
#     storeconfigs_backend=puppetdb
#
# After that if you run 'puppet agent --test' (on the same machine), you
#  should see the puppetdb being exercised (see /var/log/puppetdb)
#

include puppetdb::terminus
include puppetdb::postgresql::server

class { 'puppetdb::server':
    database        => 'postgres',
    database_host   => 'localhost',
}
