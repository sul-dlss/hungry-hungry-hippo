# frozen_string_literal: true

module Admin
  # Component for rendering a table of works on the admin user page.
  class RecentActivityListComponent < ApplicationComponent
    def initialize(items:, label:, type:)
      @items = items
      @label = label
      @type = type
      super()
    end

    attr_reader :items, :label, :type

    def values_for(item)
      [item.druid ? link_to(item.title, url_for(item)) : item.title].tap do |value|
        value << link_to(item.collection.title, url_for(item.collection)) if type == 'works'
      end
    end

    def headers
      [{ label: }].tap do |header|
        header << { label: 'Collection' } if type == 'works'
      end
    end
  end
end
