# frozen_string_literal: true

module Elements
  # Displays an item in the top breadcrumb navigation
  class BreadcrumbComponent < ApplicationComponent
    def initialize(text:, link: nil, active: false, truncate_length: 150)
      @text = text
      @link = link
      @active = active
      @truncate_length = truncate_length
      super()
    end

    attr_reader :text, :link

    def truncated_text
      truncate(text, length: @truncate_length)
    end

    def classes
      return 'breadcrumb-item active' if link.nil? || @active

      'breadcrumb-item'
    end
  end
end
