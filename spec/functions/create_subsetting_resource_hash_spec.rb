require 'spec_helper'

describe 'puppetdb::create_subsetting_resource_hash'  do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params({'test' => 1}).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('foo', 'bar').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params({'foo' => 1 }, {'bar' => 2}, {'baz' => 3}).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params({'foo' => 1, 'bar' => 2}, {'baz' => 3})
      .and_return({"'foo'"=>{"subsetting"=>"foo", "value"=>1, "baz"=>3}, "'bar'"=>{"subsetting"=>"bar", "value"=>2, "baz"=>3}}) }
end
