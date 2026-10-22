# frozen_string_literal: true

type_doc = 'Verify that a connection can be successfully established between a node and the puppetdb server. ' \
           'Its primary use is as a precondition to prevent configuration changes from being applied if the puppetdb ' \
           'server cannot be reached, but it could potentially be used for other purposes such as monitoring.'

# Raises if the value is not convertible to an integer
to_integer = ->(value) { Integer(value) }

Puppet::Type.newtype(:puppetdb_conn_validator) do
  @doc = type_doc

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  {
    puppetdb_server: 'The DNS name or IP address of the server where puppetdb should be running.',
    puppetdb_port: 'The port that the puppetdb server should be listening on.',
    test_url: 'URL to use for testing if the PuppetDB database is up',
  }.each do |param_name, description|
    newparam(param_name) { desc description }
  end

  newparam(:use_ssl) do
    desc 'Whether the connection will be attempted using https'
    defaultto true
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that puppetdb is not running; defaults to 15 seconds.'
    defaultto 15

    validate(&to_integer)
    munge(&to_integer)
  end
end
