# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle-like radio button group field
    class ToggleComponent < FieldComponent
      renders_one :left_toggle_option, Elements::Forms::ToggleOptionComponent
      renders_one :right_toggle_option, Elements::Forms::ToggleOptionComponent

      def initialize(**args)
        args[:label_classes] = merge_classes('d-block', args[:label_classes])
        super
      end
    end
  end
end
