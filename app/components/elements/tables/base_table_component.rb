# frozen_string_literal: true

module Elements
  module Tables
    # Base component for rendering a table.
    class BaseTableComponent < ApplicationComponent
      renders_one :header, 'Elements::Tables::HeaderComponent'
      # Subclasses should provide rows, e.g., renders_many :rows

      def initialize(id:, label:, classes: [], body_classes: [], show_label: true, role: nil, data: {}, # rubocop:disable Metrics/ParameterLists
                     empty_message: nil)
        @id = id
        @classes = classes
        @body_classes = body_classes
        @label = label
        @show_label = show_label
        @role = role
        @data = data
        @empty_message = empty_message
        super()
      end

      attr_reader :label, :id, :role, :data, :empty_message

      def classes
        # Provides table, table-striped, and table-sm as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[table table-h3], @classes)
      end

      def body_classes
        merge_classes(@body_classes)
      end

      def show_label?
        @show_label
      end

      def render?
        rows? || empty_message.present?
      end
    end
  end
end
