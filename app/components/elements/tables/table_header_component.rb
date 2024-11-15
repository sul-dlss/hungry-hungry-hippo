# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header section.
    class TableHeaderComponent < ApplicationComponent
      def initialize(classes:, headers: nil)
        @classes = classes
        @headers = headers
        super()
      end

      attr_reader :headers

      def render?
        headers.present?
      end

      def classes
        merge_classes(@classes)
      end
    end
  end
end
