# frozen_string_literal: true

# Helper class for terms of use
class TermsOfUseSupport
  def self.full_statement(custom_rights_statement:)
    [custom_rights_statement, I18n.t('license.terms_of_use')].compact_blank.join("\n\n")
  end
end
