# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a list in a table cell.
    class ListCellComponent < ApplicationComponent
      renders_many :items

      def initialize(item_values: [])
        # Provide items or item_values
        @item_values = item_values
        super()
      end

      attr_reader :item_values

      def list_items
        items? ? items : item_values
      end
    end
  end
end
