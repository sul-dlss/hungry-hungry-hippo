# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header section.
    class HeaderComponent < ApplicationComponent
      def initialize(headers:, classes: [], each_classes: [], each_tooltips: [])
        @classes = classes
        @headers = headers
        # Classes to apply to each header cell.
        # For example, given: ['class1', nil, ['class3']]
        # The first header cell will have 'class1', the second will have no additional classes,
        # and the third will have 'class3'.
        @each_classes = each_classes
        # See `@each_classes`
        @each_tooltips = each_tooltips
        super()
      end

      attr_reader :headers

      def render?
        headers.present?
      end

      def classes
        merge_classes(@classes)
      end

      def classes_for_header(header_index)
        merge_classes(@each_classes[header_index])
      end

      def tooltip_for_header(header_index)
        @each_tooltips.at(header_index)
      end
    end
  end
end
