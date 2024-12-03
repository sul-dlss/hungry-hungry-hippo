# frozen_string_literal: true

module Collections
  # Component for rendering a link to a collection as a header component.
  class HeaderLinkComponent < ApplicationComponent
    def initialize(collection:, level:)
      @collection = collection
      @level = level
      super()
    end
  end
end
