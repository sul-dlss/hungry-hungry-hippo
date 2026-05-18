# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :equal_form do |expected|
  match do |actual|
    actual.attributes.to_json == expected.attributes.to_json
  end

  failure_message do |actual|
    SuperDiff::EqualityMatchers::Hash.new(
      expected: serialized_form_payload(expected).deep_symbolize_keys,
      actual: serialized_form_payload(actual).deep_symbolize_keys
    ).fail
  rescue StandardError => e
    "Error in FormMatchers: #{e}"
  end

  def serialized_form_payload(form)
    return form.serializable_hash if form.respond_to?(:serializable_hash)
    return form.attributes if form.respond_to?(:attributes)

    raise TypeError, "Unsupported form payload for #{form.class}"
  end
end
