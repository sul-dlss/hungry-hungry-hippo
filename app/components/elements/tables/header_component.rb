# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header.
    class HeaderComponent < ApplicationComponent
      def initialize(label:, classes: [], tooltip: nil, style: nil)
        @label = label
        @classes = classes
        @tooltip = tooltip
        @style = style
        super()
      end

      attr_reader :label, :tooltip, :style

      def classes
        merge_classes(@classes)
      end
    end
  end
end
