# frozen_string_literal: true

module Edit
  # Component for editing contributor affiliation
  class AffiliationComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
