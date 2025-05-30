# frozen_string_literal: true

# Helper class for terms of use
class TermsOfUseSupport
  def self.full_statement(custom_rights_statement:)
    [custom_rights_statement&.strip, default_terms_of_use].compact_blank.join("\r\n\r\n")
  end

  # Removes the default terms of use from a use statement
  # @return [String] the custom rights statement
  def self.custom_rights_statement(use_statement:)
    return if use_statement.blank?

    return if use_statement == default_terms_of_use

    # Remove the default terms
    LinebreakSupport.normalize(use_statement.delete_suffix(default_terms_of_use))
  end

  def self.default_terms_of_use
    I18n.t('license.terms_of_use')
  end
end
