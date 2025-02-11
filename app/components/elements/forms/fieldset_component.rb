# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering a form fieldset.
    class FieldsetComponent < ApplicationComponent
      renders_one :legend # Provide legend or label

      def initialize(label: nil, hidden_label: false, classes: [], label_classes: [], legend_classes: [], # rubocop:disable Metrics/ParameterLists
                     data: {}, id: nil)
        @label = label
        @hidden_label = hidden_label
        @classes = classes
        @data = data
        @id = id
        @label_classes = label_classes
        @legend_classes = legend_classes
        super()
      end

      attr_reader :label, :data, :id

      def label_classes
        merge_classes(@label_classes, @hidden_label ? 'visually-hidden' : 'form-label fw-bold')
      end

      def classes
        merge_classes('form-fieldset', @classes)
      end

      def legend_classes
        merge_classes(@legend_classes)
      end
    end
  end
end
