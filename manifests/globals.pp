# Global configuration class for PuppetDB. See README.md for more details.
class puppetdb::globals (
  $version                      = 'present',
  $database                     = 'postgres',
  Stdlib::Absolutepath $puppet_confdir = $settings::confdir,
) {
  if !(fact('os.family') in ['RedHat', 'Suse', 'Archlinux', 'Debian', 'OpenBSD', 'FreeBSD']) {
    fail("${module_name} does not support your osfamily ${fact('os.family')}")
  }
}
