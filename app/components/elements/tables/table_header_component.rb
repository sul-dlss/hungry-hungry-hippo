# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header section.
    class TableHeaderComponent < ApplicationComponent
      def initialize(classes:, headers: nil)
        # If value is not provided, content block will be rendered instead.
        @classes = classes
        @headers = headers
        super()
      end

      attr_reader :classes, :headers
    end
  end
end
