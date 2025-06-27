# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table row.
    class RowComponent < ApplicationComponent
      renders_many :cells

      def initialize(label: nil, first_value: nil, values: [], id: nil, tooltip: nil)
        @label = label
        # Provide either values or cells (e.g. for content files).
        @values = values
        @first_value = first_value
        @id = id
        @tooltip = tooltip
        super()
      end

      attr_reader :label, :values, :id, :tooltip, :first_value

      def empty_cell?
        label.present? && values.empty? && !cells?
      end
    end
  end
end
