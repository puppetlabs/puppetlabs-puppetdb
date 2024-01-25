# frozen_string_literal: true

RSpec.configure do |c|
  if ENV['GITHUB_ACTIONS']
    c.formatter = 'RSpec::Github::Formatter'
    c.color_mode = :on
  end
end
