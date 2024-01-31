# frozen_string_literal: true

require 'spec_helper'

valid = {
  'puppetdb-read': {
    database_name:     'puppetdb',
    database_username: 'monitor',
    puppetdb_server:   'localhost',
  },
  'monitor': {
    database_name:     'opensesame',
    database_username: 'grover',
    puppetdb_server:   'rainbow',
  },
}

invalid = {
  'no params': {},
}

describe 'puppetdb::database::postgresql_ssl_rules' do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:pre_condition) { 'include postgresql::server' }
  let(:name) { title }
  let(:args) { params }

  valid.each do |name, params|
    context "for valid #{name}" do
      include_examples 'puppetdb::database::postgresql_ssl_rules' do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end

  invalid.each do |name, params|
    context "for invalid #{name}" do
      include_examples 'puppetdb::database::postgresql_ssl_rules', Puppet::Error do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end
end
