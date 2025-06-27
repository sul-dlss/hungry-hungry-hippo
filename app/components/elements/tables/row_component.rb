# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table row.
    class RowComponent < ApplicationComponent
      renders_many :cells

      def initialize(label: nil, first_value: nil, values: [], id: nil, tooltip: nil)
        # Provide either label or first_value but not both; these are rendered in the first column
        # label renders with <th> (bold), first_value is a normal <td>
        @label = label
        @first_value = first_value
        # Provide either values or cells (e.g. for content files).
        @values = values
        @id = id
        @tooltip = tooltip

        raise ArgumentError if label.present? && first_value.present?

        super()
      end

      attr_reader :label, :values, :id, :tooltip, :first_value

      def empty_cell?
        label.present? && values.empty? && !cells?
      end
    end
  end
end
