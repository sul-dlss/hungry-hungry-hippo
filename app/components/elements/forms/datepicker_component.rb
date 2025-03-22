# frozen_string_literal: true

module Elements
  module Forms
    # Component for form date fields
    class DatepickerComponent < FieldComponent
      def initialize(min: nil, max: nil, **args)
        @min = min
        @max = max
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        args[:input_classes] =
          merge_classes(args[:readonly] ? 'form-control-plaintext' : 'form-control', args[:input_classes])
        super(**args)
      end

      attr_reader :min, :max
    end
  end
end
