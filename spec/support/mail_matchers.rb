# frozen_string_literal: true

RSpec::Matchers.define :match_body do |expected|
  match do |actual|
    @actual_body = actual.body.encoded.gsub(/\r\n */, ' ')
    @actual_body.include?(expected)
  end

  failure_message do
    "expected that #{@actual_body} match #{expected}"
  end
end
