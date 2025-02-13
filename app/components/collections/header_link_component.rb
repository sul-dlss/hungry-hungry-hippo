# frozen_string_literal: true

module Collections
  # Component for rendering a link to a collection as a header component.
  class HeaderLinkComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
      @level = level
      super()
    end

    def level
      :h3
    end

    def classes
      'h4'
    end
  end
end
