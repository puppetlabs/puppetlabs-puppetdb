# frozen_string_literal: true

require 'spec_helper'

valid = {
  'grant read on new objects from blah to blah': {
    database_read_only_username: 'puppetdb-read',
    database_name:               'puppetdb',
    schema:                      'public',
  },
}

invalid = {
  'no params': {},
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
