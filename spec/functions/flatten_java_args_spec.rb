require 'spec_helper'

describe 'puppetdb::flatten_java_args' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_return('""') }
  it { is_expected.to run.with_params({ 'test' => 1 }, 'foo' => 2).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('foo').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('foo' => 1).and_return('"foo1"') }
end
