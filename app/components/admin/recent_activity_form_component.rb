# frozen_string_literal: true

module Admin
  # Component for rendering the recent activity form.
  class RecentActivityFormComponent < ApplicationComponent
    def initialize(form:, url:, sort_by: nil)
      @form = form
      @url = url
      @sort_by = sort_by
      super()
    end

    attr_reader :form, :url, :sort_by

    def days_limit_options
      RecentActivityForm::DAYS_LIMIT_OPTIONS
    end
  end
end
