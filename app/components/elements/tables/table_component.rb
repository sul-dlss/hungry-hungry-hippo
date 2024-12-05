# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table.
    class TableComponent < ApplicationComponent
      renders_many :rows, 'Elements::Tables::TableRowComponent'
      renders_one :header, 'Elements::Tables::TableHeaderComponent'

      def initialize(id:, classes: [], body_classes: [], label: nil)
        @id = id
        @classes = classes
        @body_classes = body_classes
        @label = label
        super()
      end

      attr_reader :label, :id

      def classes
        # Provides table, table-striped, and table-sm as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[table table-h3], @classes)
      end

      def body_classes
        merge_classes(@body_classes)
      end

      def render?
        rows?
      end
    end
  end
end
