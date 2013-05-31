# Class: puppetdb::ssl
#
# This class provides a simple way to configure SSL certificates for puppetdb,
# including the truststore and keystore.
#
# It requires the puppetlabs/java_ks module in order to work.
#
# This class is called by puppetdb::server.
# You shouldn't have to call it directly.
#
# Parameters:
#   ['ca_cert']            - The SSL CA certificate used.
#   ['ssl_cert']           - The SSL certificate for $ssl_listen_address,
#                            signed by the CA.
#   ['ssl_private_key']    - The SSL private key for $ssl_listen_address.
#                            `/etc/puppetdb/conf.d`.
#
# Actions:
# - Creates and manages the truststore/keystore for a puppetdb server
#
# Requires:
# - `puppetlabs/java_ks`
#
# Sample Usage:
#     class { 'puppetdb::ssl':
#         ssl_cert        => '/root/pub.pem',
#         ssl_private_key => '/root/priv.pem',
#     }
class puppetdb::ssl (
  $puppet_ssldir           = $puppetdb::params::puppet_ssldir,
  $ssl_cert                = "${puppet_ssldir}/certs/${ssl_listen_address}.pem",
  $ssl_private_key         = "${puppet_ssldir}/private_keys/${ssl_listen_address}.pem",
  $ssl_listen_address      = $puppetdb::params::ssl_listen_address,
) inherits puppetdb::params {

  java_ks { "${ssl_listen_address}:/etc/puppetdb/ssl/keystore.jks":
    ensure        => latest,
    certificate   => $ssl_cert,
    private_key   => $ssl_private_key,
    password_file => '/etc/puppetdb/ssl/puppetdb_keystore_pw.txt',
  }
}
