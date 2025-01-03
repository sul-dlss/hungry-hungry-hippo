# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a row for a treegrid branch.
    class TreegridBranchRowComponent < ApplicationComponent
      def initialize(level:, label:, empty_cells: 0)
        @level = level
        @label = label
        @empty_cells = empty_cells
        super()
      end

      attr_reader :level, :label, :empty_cells

      def styles
        "padding-left: #{(level - 1) * 20}px;"
      end
    end
  end
end
