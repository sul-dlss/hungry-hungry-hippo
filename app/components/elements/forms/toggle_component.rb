# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle-like radio button group field
    class ToggleComponent < FieldComponent
      def initialize(options:, **)
        @options = options
        super(**)
      end

      attr_reader :options
    end
  end
end
