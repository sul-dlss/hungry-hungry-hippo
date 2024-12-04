# frozen_string_literal: true

module PublicationDate
  # Component for editing publication dates
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
