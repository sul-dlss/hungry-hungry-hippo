# frozen_string_literal: true

module Admin
  # Admin form object for searching by druid
  class DruidSearchForm < ApplicationForm
    attribute :druid, :string
    normalizes :druid, with: lambda { |value|
      normalized = value.strip
      next normalized if normalized.blank? || normalized.starts_with?('druid:')

      "druid:#{normalized}"
    }
    validate :collection_or_work_present

    def collection
      return @collection if defined?(@collection)

      @collection = Collection.find_by(druid:)
    end

    def work
      return @work if defined?(@work)

      @work = Work.find_by(druid:)
    end

    def collection_or_work_present
      return if collection.present? || work.present?

      errors.add(:druid, I18n.t('admin_druid_search_form.fields.druid.validations.not_found'))
    end
  end
end
