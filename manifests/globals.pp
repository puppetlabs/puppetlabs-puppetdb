# global configuration class for PuppetDB
#
class puppetdb::globals (
  $version                      = 'present',
  $database                     = 'postgres',
  Stdlib::Absolutepath $puppet_confdir = $settings::confdir,
) {
  if !(fact('os.family') in ['RedHat', 'Suse', 'Archlinux', 'Debian', 'OpenBSD', 'FreeBSD']) {
    fail("${module_name} does not support your osfamily ${fact('os.family')}")
  }
}
