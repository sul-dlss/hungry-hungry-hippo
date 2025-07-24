# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a row for a treegrid leaf.
    class TreegridLeafRowComponent < ApplicationComponent
      renders_one :label_content
      renders_many :cells
      def initialize(level:, label: nil, badge_content: nil)
        @level = level
        @label = label
        @badge_content = badge_content
        super()
      end

      attr_reader :level, :label, :badge_content

      def styles
        "padding-left: #{((level - 1) * 20) + 8}px;"
      end

      def badge
        return unless badge_content

        tag.span badge_content, class: 'badge new-file ms-2'
      end
    end
  end
end
