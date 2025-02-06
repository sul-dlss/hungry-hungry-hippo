# frozen_string_literal: true

module Elements
  module Forms
    # Component for form text fields
    class TextFieldComponent < FieldComponent
      def initialize(**args)
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        args[:input_classes] =
          merge_classes(args[:readonly] ? 'form-control-plaintext' : 'form-control', args[:input_classes])
        super
      end
    end
  end
end
