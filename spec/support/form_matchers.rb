# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :equal_form do |expected|
  match do |actual|
    actual.attributes.to_json == expected.attributes.to_json
  end

  failure_message do |actual|
    SuperDiff::EqualityMatchers::Hash.new(
      expected: expected.attributes.deep_symbolize_keys,
      actual: actual.attributes.deep_symbolize_keys
    ).fail
  rescue StandardError => e
    "Error in FormMatchers: #{e}"
  end
end
