# frozen_string_literal: true

module Admin
  # Admin form object for moving a work to a different collection.
  class MoveForm < ApplicationForm
    attribute :collection_druid, :string
    normalizes :collection_druid, with: lambda { |value|
      next value if value.blank? || value.starts_with?('druid:')

      "druid:#{value}"
    }
    validates_with Admin::MoveFormValidator

    attribute :content_id, :integer
    attribute :work_form

    def collection
      return @collection if defined?(@collection)

      @collection = Collection.find_by(druid: collection_druid)
    end
  end
end
