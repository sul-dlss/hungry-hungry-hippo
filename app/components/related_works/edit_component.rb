# frozen_string_literal: true

module RelatedWorks
  # Component for editing related works
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

    def options
      RelatedWorkForm::RELATIONSHIP_TYPES.map do |relationship|
        [helpers.t("related_works.edit.fields.relationship.options.#{relationship}"), relationship]
      end
    end

    def prompt
      'Select...'
    end
  end
end
