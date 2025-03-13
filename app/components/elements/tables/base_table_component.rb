# frozen_string_literal: true

module Elements
  module Tables
    # Base component for rendering a table.
    class BaseTableComponent < ApplicationComponent
      renders_many :headers, Elements::Tables::HeaderComponent
      renders_one :caption
      # Subclasses should provide rows, e.g., renders_many :rows

      def initialize(id:, label: nil, classes: [], head_classes: [], body_classes: [], show_label: true, role: nil, # rubocop:disable Metrics/ParameterLists
                     data: {}, empty_message: nil)
        @id = id
        @classes = classes
        @body_classes = body_classes
        @label = label
        @show_label = show_label
        @role = role
        @data = data
        @empty_message = empty_message
        @head_classes = head_classes
        raise ArgumentError, 'Subclasses must provide rows' unless respond_to?(:rows)

        super()
      end

      attr_reader :label, :id, :role, :data, :empty_message

      def before_render
        raise ArgumentError, 'Must provide label or caption' unless label.present? || caption?
      end

      def classes
        # Provides table, table-striped, and table-sm as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[table table-h3], @classes)
      end

      def head_classes
        merge_classes(@head_classes)
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
