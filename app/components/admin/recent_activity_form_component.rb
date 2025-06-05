# frozen_string_literal: true

module Admin
  # Component for rendering the recent activity form.
  class RecentActivityFormComponent < ApplicationComponent
    def initialize(form:, type:)
      @form = form
      @type = type
      super()
    end

    attr_reader :form, :type

    def days_limit_options
      RecentActivityForm::DAYS_LIMIT_OPTIONS
    end
  end
end
