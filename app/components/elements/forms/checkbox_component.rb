# frozen_string_literal: true

module Elements
  module Forms
    # Component for form checkbox field
    class CheckboxComponent < FieldComponent
      def initialize(**args)
        args[:container_classes] = merge_classes('form-check', args[:container_classes])
        args[:input_classes] = merge_classes('form-check-input', args[:input_classes])
        super
      end

      attr_reader :value
    end
  end
end
