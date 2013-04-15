require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

RSpec.configure do |c|
  # Project root for the firewall code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  # This is where we 'setup' the nodes before running our tests
  c.system_setup_block = proc do
    # TODO: find a better way of importing this into this namespace
    include RSpecSystemPuppet::Helpers

    # Install puppet
    puppet_install
    puppet_master_install

    # Copy this module into the module path of the test node
    puppet_module_install(:source => proj_root, :module_name => 'puppetdb')
  end
end
