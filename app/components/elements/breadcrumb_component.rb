# frozen_string_literal: true

module Elements
  # Displays an item in the top bread crumb navigation
  class BreadcrumbComponent < ApplicationComponent
    def initialize(text:, link: nil, active: false)
      @text = text
      @link = link
      @active = active
      super()
    end

    attr_reader :text, :link

    def truncated_title
      truncate(text, length: 150, separator: ' ')
    end

    def classes
      return 'breadcrumb-item active' if link.nil? || @active

      'breadcrumb-item'
    end
  end
end
