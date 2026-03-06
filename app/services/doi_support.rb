# frozen_string_literal: true

# Support for DOI identifiers.
class DoiSupport
  def self.identifier(doi)
    return if doi.blank?

    doi.delete_prefix('https://doi.org/')
  end
end
