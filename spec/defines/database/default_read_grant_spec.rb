# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::database::default_read_grant' do
  valid = {
    'standard': {
      database_name:               'puppetdb',
      schema:                      'public',
      database_username:           'puppetdb',
      database_read_only_username: 'puppetdb-read',
    }
  }

  invalid = {
    'no params': {},
    'without database_name': {
      schema:                      'public',
      database_username:           'puppetdb',
      database_read_only_username: 'puppetdb-read',
    }
  }

  let(:facts) { on_supported_os.take(1).first[1] }
  let(:pre_condition) { 'include postgresql::server' }
  let(:name) { title }
  let(:args) { params }

  context 'with valid parameters' do
    valid.each do |name, params|
      context name do
        include_examples 'puppetdb::database::default_read_grant' do
          let(:title) { name.to_s }
          let(:params) { params }
        end
      end
    end
  end

  context 'with invalid parameters' do
    invalid.each do |name, params|
      context name do
        include_examples 'puppetdb::database::default_read_grant', Puppet::Error do
          let(:title) { name.to_s }
          let(:params) { params }
        end
      end
    end
  end
end
