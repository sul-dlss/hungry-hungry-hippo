# frozen_string_literal: true

module Admin
  # Admin form object for searching by druid
  class DruidSearchForm < ApplicationForm
    before_validation :normalize_druid
    attribute :druid, :string
    validate :collection_or_work_present

    def collection
      @collection ||= Collection.find_by(druid:)
    end

    def work
      @work ||= Work.find_by(druid:)
    end

    def normalize_druid
      return if druid.starts_with?('druid:') || druid.blank?

      self.druid = druid.prepend('druid:')
    end

    def collection_or_work_present
      return if collection.present? || work.present?

      errors.add(:druid, 'not found')
    end
  end
end
