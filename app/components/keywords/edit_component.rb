# frozen_string_literal: true

module Keywords
  # Component for editing keywords
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
