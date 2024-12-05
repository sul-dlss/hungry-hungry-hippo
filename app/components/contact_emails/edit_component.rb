# frozen_string_literal: true

module ContactEmails
  # Component for editing contact emails
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
