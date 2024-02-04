# @summary global configuration class for PuppetDB
#
# @param version
#   The version of the `puppetdb` package that should be installed. You may specify
#   an explicit version number, 'present', or 'latest' (defaults to 'present').
#
# @param puppet_confdir
#   Puppet's config directory. Defaults to `/etc/puppetlabs/puppet`.
#
class puppetdb::globals (
  $version                      = 'present',
  Stdlib::Absolutepath $puppet_confdir = $settings::confdir,
) {
  if !(fact('os.family') in ['RedHat', 'Suse', 'Archlinux', 'Debian', 'OpenBSD', 'FreeBSD']) {
    fail("${module_name} does not support your osfamily ${fact('os.family')}")
  }
}
