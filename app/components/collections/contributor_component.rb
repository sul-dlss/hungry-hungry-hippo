# frozen_string_literal: true

module Collections
  # Component for editing collection contributors
  class ContributorComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
