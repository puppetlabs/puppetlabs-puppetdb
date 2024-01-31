# Rough conversion of grepping in the puppet source:
# grep defaultfor lib/puppet/provider/service/*.rb
# Source https://github.com/voxpupuli/voxpupuli-test/blob/master/lib/voxpupuli/test/facts.rb
add_custom_fact :service_provider, ->(_os, facts) do
  os = RSpec.configuration.facterdb_string_keys ? facts['os'] : facts[:os]
  case os['family'].downcase
  when 'archlinux'
    'systemd'
  when 'darwin'
    'launchd'
  when 'debian'
    'systemd'
  when 'freebsd'
    'freebsd'
  when 'gentoo'
    'openrc'
  when 'openbsd'
    'openbsd'
  when 'redhat'
    (os['release']['major'].to_i >= 7) ? 'systemd' : 'redhat'
  when 'suse'
    (os['release']['major'].to_i >= 12) ? 'systemd' : 'redhat'
  when 'windows'
    'windows'
  else
    'init'
  end
end
