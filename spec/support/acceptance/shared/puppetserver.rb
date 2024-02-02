# frozen_string_literal: true

shared_examples 'puppetserver' do
  let(:pp) { File.read(File.join(File.dirname(__FILE__), 'puppetserver.pp')) }

  it 'applies idempotently' do
    idempotent_apply(pp, debug: ENV.key?('DEBUG'))
  end
end
