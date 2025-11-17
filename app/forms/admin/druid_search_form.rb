# frozen_string_literal: true

module Admin
  # Admin form object for searching by druid
  class DruidSearchForm < ApplicationForm
    before_validation :normalize_druid
    attribute :druid, :string
    validate :collection_or_work_present

    def collection
      return @collection if defined?(@collection)

      @collection = Collection.find_by(druid:)
    end

    def work
      return @work if defined?(@work)

      @work = Work.find_by(druid:)
    end

    def normalize_druid
      druid.strip! # remove any trailing or leading whitespace the user may have inadvertently entered via a copy/paste

      return if druid.starts_with?('druid:') || druid.blank?

      self.druid = druid.prepend('druid:')
    end

    def collection_or_work_present
      return if collection.present? || work.present?

      errors.add(:druid, 'druid not found')
    end
  end
end
