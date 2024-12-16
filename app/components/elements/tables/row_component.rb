# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table row.
    class RowComponent < ApplicationComponent
      renders_many :cells

      def initialize(label: nil, values: [], id: nil)
        @label = label
        # Provide either values or cells.
        @values = values
        @id = id
        super()
      end

      attr_reader :label, :values, :id
    end
  end
end
