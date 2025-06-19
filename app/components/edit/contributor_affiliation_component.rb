# frozen_string_literal: true

module Edit
  # Component for editing contributors
  class ContributorAffiliationComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
