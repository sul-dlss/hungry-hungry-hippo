# frozen_string_literal: true

module Elements
  module Forms
    # Component for form textarea fields
    class TextareaFieldComponent < FieldComponent
      def initialize(rows: nil, **args)
        @rows = rows
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        super(**args)
      end

      attr_reader :rows
    end
  end
end
