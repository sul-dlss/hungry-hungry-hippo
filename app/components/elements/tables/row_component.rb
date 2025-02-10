# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table row.
    class RowComponent < ApplicationComponent
      renders_many :cells
      renders_many :items

      def initialize(label: nil, values: [], id: nil)
        @label = label
        # Provide either values, cells (e.g. for content files),
        # or items (list of values for a field such as related links )
        @values = values
        @id = id
        super()
      end

      attr_reader :label, :values, :id

      def empty_cell?
        label.present? && values.empty? && !items? && !cells?
      end
    end
  end
end
