# frozen_string_literal: true

module Admin
  # Component for rendering a table of works on the admin user page.
  class RecentActivityListComponent < ApplicationComponent
    def initialize(items:, label:)
      @items = items
      @label = label
      super()
    end

    attr_reader :items, :label

    def values_for(item)
      [
        item.druid ? link_to(item.title, url_for(item)) : item.title
      ]
    end
  end
end
