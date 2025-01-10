# frozen_string_literal: true

module Elements
  module Forms
    # Component for form date fields
    class DatepickerComponent < FieldComponent
      def initialize(min: Date.now, max: nil, **args)
        @min = min
        @max = max
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        args[:data] = { datepicker_target: 'input' }.merge(args[:data] || {})
        args[:width] = 200
        super(**args)
      end

      def picker_data
        {
          controller: 'datepicker',
          datepicker_min_value: @min&.iso8601,
          datepicker_max_value: @max&.iso8601
        }
      end
    end
  end
end
