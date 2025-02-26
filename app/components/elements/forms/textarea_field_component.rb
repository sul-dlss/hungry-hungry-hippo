# frozen_string_literal: true

module Elements
  module Forms
    # Component for form textarea fields
    class TextareaFieldComponent < FieldComponent
      def initialize(maxlength: nil, rows: nil, **args)
        @maxlength = maxlength
        @rows = rows
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        super(**args)
      end

      attr_reader :maxlength, :rows
    end
  end
end
