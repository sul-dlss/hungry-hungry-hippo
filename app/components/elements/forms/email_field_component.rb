# frozen_string_literal: true

module Elements
  module Forms
    # Component for form email fields
    class EmailFieldComponent < FieldComponent
      def initialize(**args)
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        super
      end
    end
  end
end
