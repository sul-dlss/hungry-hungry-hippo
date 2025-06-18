# frozen_string_literal: true

module Collections
  module Show
    # Component for rendering a dropdown of sorting options.
    class SortDropdownComponent < ApplicationComponent
      renders_many :sort_options, lambda { |label:, link:|
        tag.li do
          link_to label, link, class: 'dropdown-item'
        end
      }

      def initialize(classes: [])
        @classes = classes
        super()
      end

      def classes
        merge_classes('dropdown', @classes)
      end
    end
  end
end
