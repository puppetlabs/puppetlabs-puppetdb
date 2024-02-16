# frozen_string_literal: true

require 'spec_helper'

defaults = {
  database_read_only_username: 'puppetdb-read',
  database_name:               'puppetdb',
  schema:                      'public',
}

valid = {
  'grant read on new objects from blah to blah': defaults,
  'grant read on new objects from blah to blah with port': defaults.merge({ database_port: 5433 }),
}

invalid = {
  'no params': {},
  'invalid data type': defaults.merge({ database_port: '5433' }),
}

describe 'puppetdb::database::read_grant' do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:pre_condition) { 'include postgresql::server' }
  let(:name) { title }
  let(:args) { params }

  valid.each do |name, params|
    context "for valid #{name}" do
      include_examples 'puppetdb::database::read_grant' do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end

  invalid.each do |name, params|
    context "for invalid #{name}" do
      include_examples 'puppetdb::database::read_grant', Puppet::Error do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end
end
