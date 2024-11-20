# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :equal_model do |expected, attributes|
  ignored = %w[id updated_at created_at] + Array(attributes).map(&:to_s)
  match do |actual|
    actual.attributes.except(*ignored).to_json == expected.attributes.except(*ignored).to_json
  end

  failure_message do |actual|
    SuperDiff::EqualityMatchers::Hash.new(
      expected: expected.attributes.except(*ignored).deep_symbolize_keys,
      actual: actual.attributes.except(*ignored).deep_symbolize_keys
    ).fail
  rescue StandardError => e
    "Error in ModelMatchers: #{e}"
  end
end
