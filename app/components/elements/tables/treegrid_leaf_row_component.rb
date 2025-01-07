# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a row for a treegrid leaf.
    class TreegridLeafRowComponent < ApplicationComponent
      renders_many :cells
      def initialize(level:, label:)
        @level = level
        @label = label
        super()
      end

      attr_reader :level, :label

      def styles
        "padding-left: #{((level - 1) * 20) + 8}px;"
      end
    end
  end
end
