# frozen_string_literal: true

require 'spec_helper'

valid = {
  'puppetdb-read': {
    read_database_username: 'puppetdb-read',
    database_name:          'puppetdb',
    password_hash:          'blah',
    database_owner:         'puppetdb',
  },
  'spectest': {
    read_database_username: 'spectest-read',
    database_name:          'spectest',
    database_owner:         'spectest',
  },
}

invalid = {
  'no params': {},
}

describe 'puppetdb::database::read_only_user', type: :define do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:pre_condition) { 'include postgresql::server' }
  let(:name) { title }
  let(:args) { params }

  valid.each do |name, params|
    context "for valid #{name}" do
      include_examples 'puppetdb::database::read_only_user' do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end

  invalid.each do |name, params|
    context "for invalid #{name}" do
      include_examples 'puppetdb::database::read_only_user', Puppet::Error do
        let(:title) { name.to_s }
        let(:params) { params }
      end
    end
  end
end
