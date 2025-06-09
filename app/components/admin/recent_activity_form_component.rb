# frozen_string_literal: true

module Admin
  # Component for rendering the recent activity form.
  class RecentActivityFormComponent < ApplicationComponent
    def initialize(form:, url:)
      @form = form
      @url = url
      super()
    end

    attr_reader :form, :url

    def days_limit_options
      RecentActivityForm::DAYS_LIMIT_OPTIONS
    end
  end
end
