require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  # Project root for the firewall code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  # Import puppet helpers
  c.include RSpecSystemPuppet::Helpers
  c.extend RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Time sync
    if node.facts['osfamily'] == 'Debian' then
      shell('apt-get install -y ntpdate')
    elsif node.facts['osfamily'] == 'RedHat' then
      if node.facts['lsbmajdistrelease'] == '5' then
        shell('yum install -y ntp')
      else
        shell('yum install -y ntpdate')
      end
    end
    shell('ntpdate -u pool.ntp.org')

    # Install puppet
    puppet_install
    puppet_master_install

    # Copy this module into the module path of the test node
    puppet_module_install(:source => proj_root, :module_name => 'puppetdb')
  end
end
