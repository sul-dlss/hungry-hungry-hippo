# frozen_string_literal: true

# Methods for working with ORCID identifiers and URLs.
class OrcidSupport
  def self.orcid_url(orcid)
    return if orcid.blank?

    "#{Settings.orcid.url}/#{orcid}"
  end

  def self.orcid_id(url)
    return if url.blank?

    url.split('/').last
  end
end
