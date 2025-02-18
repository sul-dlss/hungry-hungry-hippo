# frozen_string_literal: true

module Admin
  # Component for rendering a dropdown of functions.
  class FunctionDropdownComponent < ApplicationComponent
    renders_many :functions, lambda { |label:, link:, data: {}|
      tag.li do
        link_to label, link, class: 'dropdown-item', data:
      end
    }

    def initialize(classes: [])
      @classes = classes
      super()
    end

    def classes
      merge_classes('dropdown', @classes)
    end

    def render?
      helpers.allowed_to?(:show?, with: AdminPolicy) && functions?
    end
  end
end
