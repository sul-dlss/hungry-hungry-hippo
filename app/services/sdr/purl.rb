# frozen_string_literal: true

module Sdr
  # Methods for working with Purls.
  class Purl
    def self.from_druid(druid:)
      return if druid.blank?

      "#{Settings.purl.url}/#{druid.delete_prefix('druid:')}"
    end
  end
end
