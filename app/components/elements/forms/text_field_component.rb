# frozen_string_literal: true

module Elements
  module Forms
    # Component for form text fields
    class TextFieldComponent < FieldComponent
      def initialize(**args)
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        args[:render_errors] = args.key?(:render_errors) ? args[:render_errors] : true
        super
      end
    end
  end
end
