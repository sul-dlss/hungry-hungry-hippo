# frozen_string_literal: true

module RelatedLinks
  # Component for editing related links
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
