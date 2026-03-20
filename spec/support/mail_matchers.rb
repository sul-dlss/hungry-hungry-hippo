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

RSpec::Matchers.define :match_body_in_order do |*expected_parts|
  match do |actual|
    @actual_body = actual.body.encoded.gsub(/\r\n */, ' ')
    search_start = 0

    expected_parts.all? do |expected_part|
      index = @actual_body.index(expected_part, search_start)
      if index.nil?
        @missing_part = expected_part
        false
      else
        search_start = index + expected_part.length
        true
      end
    end
  end

  failure_message do
    "expected that #{@actual_body} match #{expected_parts.inspect} in order; failed on #{@missing_part.inspect}"
  end
end
