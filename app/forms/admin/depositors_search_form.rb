# frozen_string_literal: true

module Admin
  # Admin form object for searching for depositor information
  class DepositorsSearchForm < ApplicationForm
    attribute :druids, :string
    normalizes :druids, with: lambda { |value|
      value.split(/\s+/).uniq.filter_map do |druid|
        next if druid.blank?

        druid.starts_with?('druid:') ? druid : "druid:#{druid}"
      end.join(' ')
    }
    validate :works_or_collections_present

    def druid_list
      druids.split(/\s+/)
    end

    def works_or_collections_present
      druid_list.each do |druid|
        next if Work.exists?(druid:) || Collection.exists?(druid:)

        errors.add(:druids, I18n.t('admin_depositor_search_form.fields.druids.validations.not_found', druid:))
      end
    end
  end
end
