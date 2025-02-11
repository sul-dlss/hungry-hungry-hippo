# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle-like radio button group field
    class ToggleComponent < FieldComponent
      renders_one :left_toggle_option, lambda { |form:, field_name:, label:, value:, label_data: {}, data: {}|
        label_data[:action] = merge_actions(label_data[:action], 'click->toggle#leftSelected')
        label_data[:toggle_target] = 'leftLabel'
        data[:toggle_target] = 'leftRadio'
        Elements::Forms::ToggleOptionComponent.new(form:, field_name:, label:, value:, data:, label_data:)
      }
      renders_one :right_toggle_option, lambda { |form:, field_name:, label:, value:, label_data: {}, data: {}|
        label_data[:action] = merge_actions(label_data[:action], 'click->toggle#rightSelected')
        label_data[:toggle_target] = 'rightLabel'
        data[:toggle_target] = 'rightRadio'
        Elements::Forms::ToggleOptionComponent.new(form:, field_name:, label:, value:, data:, label_data:)
      }

      def initialize(**args)
        args[:label_classes] = merge_classes('d-block', args[:label_classes])
        super
      end

      def data
        { controller: 'toggle' }
      end
    end
  end
end
