# frozen_string_literal: true

module Admin
  # Admin form object for searching for depositor information
  class DepositorsSearchForm < ApplicationForm
    before_validation :normalize_druids
    attribute :druids, :string
    validate :works_or_collections_present

    def druid_list
      druids.split(/\s+/)
    end

    def normalize_druids
      self.druids = druid_list.uniq.filter_map do |druid|
        next if druid.blank?

        druid.starts_with?('druid:') ? druid : druid.prepend('druid:')
      end.join(' ')
    end

    def works_or_collections_present
      druid_list.each do |druid|
        next if Work.exists?(druid:) || Collection.exists?(druid:)

        errors.add(:druids, "#{druid} not found in Works or Collections")
      end
    end
  end
end
