# frozen_string_literal: true

module Keywords
  # Component for editing keywords
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

    def unique_field_id
      form.field_id('').delete_suffix('_')
    end
  end
end
