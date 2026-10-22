# frozen_string_literal: true

shared_examples 'puppetserver' do
  let(:pp) { File.read(File.join(File.dirname(__FILE__), 'puppetserver.pp')) }

  it 'applies idempotently' do
    expect { idempotent_apply(pp, debug: ENV.key?('DEBUG')) }.not_to raise_error
  end
end
