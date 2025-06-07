# frozen_string_literal: true

module Admin
  # Component for rendering a table of works on the admin user page.
  class RecentActivityListComponent < ApplicationComponent
    def initialize(items:, label:, presenter:, headers:)
      @items = items
      @label = label
      @presenter = presenter
      @headers = headers
      @empty_message = "No #{label.downcase} activity for time period selected."
      super()
    end

    attr_reader :empty_message, :items, :label, :presenter, :headers
  end
end
