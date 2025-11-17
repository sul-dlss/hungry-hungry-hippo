# frozen_string_literal: true

module Admin
  # Admin form object for moving a work to a different collection.
  class MoveForm < ApplicationForm
    before_validation :normalize_druid
    attribute :collection_druid, :string
    validates_with Admin::MoveFormValidator

    attribute :content_id, :integer
    attribute :work_form

    def collection
      return @collection if defined?(@collection)

      @collection = Collection.find_by(druid: collection_druid)
    end

    def normalize_druid
      return if collection_druid.starts_with?('druid:') || collection_druid.blank?

      self.collection_druid = collection_druid.prepend('druid:')
    end
  end
end
