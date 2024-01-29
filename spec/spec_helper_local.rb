# frozen_string_literal: true

Dir['./spec/support/unit/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  if ENV['GITHUB_ACTIONS']
    require 'rspec/github'
    c.formatter = :progress
    c.add_formatter 'RSpec::Github::Formatter'
    c.color_mode = :on
  end

  c.fail_if_no_examples = true
  c.silence_filter_announcements = true

  c.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
