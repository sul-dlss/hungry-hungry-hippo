# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table body.
    class TableBodyComponent < ApplicationComponent
      def initialize(classes: nil, rows: nil)
        # If value is not provided, content block will be rendered instead.
        @classes = classes
        @rows = rows
        super()
      end

      attr_reader :classes, :rows
    end
  end
end
