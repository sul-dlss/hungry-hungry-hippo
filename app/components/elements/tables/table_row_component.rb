# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table row.
    class TableRowComponent < ApplicationComponent
      def initialize(label: nil, values: nil)
        @label = label
        # If value is not provided, content block will be rendered instead.
        @values = values
        super()
      end

      attr_reader :label, :values
    end
  end
end
