# frozen_string_literal: true

module Admin
  # Component for rendering a table of works on the admin user page.
  class RecentActivityListComponent < ApplicationComponent
    def initialize(rows:, label:, headers:)
      @rows = rows
      @label = label
      @headers = headers
      super()
    end

    attr_reader :rows, :label, :headers

    def empty_message
      "No #{label.downcase} activity for time period selected."
    end
  end
end
