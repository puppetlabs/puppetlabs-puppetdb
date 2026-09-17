# frozen_string_literal: true

# Same rspec-puppet-facts idiom .rubocop.yml exempts for spec_helper.rb (D-07); kept here instead.
include RspecPuppetFacts # rubocop:disable Style/MixinUsage

Dir['./spec/support/unit/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.fail_if_no_examples = true
  c.silence_filter_announcements = true

  c.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
