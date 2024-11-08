# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a table row on the work show page.
    class TableRowComponent < ApplicationComponent
      def initialize(label:, value: nil)
        @label = label
        # If value is not provided, content block will be rendered instead.
        @value = value
        super()
      end

      attr_reader :label, :value
    end
  end
end
