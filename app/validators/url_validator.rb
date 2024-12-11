# frozen_string_literal: true

# Validate URL-type attributes
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if valid?(value)

    record.errors.add(attribute, options[:message] || 'must be a valid HTTP/S URL')
  end

  def valid?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
