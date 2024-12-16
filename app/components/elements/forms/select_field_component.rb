# frozen_string_literal: true

module Elements
  module Forms
    # Component for form select fields
    class SelectFieldComponent < FieldComponent
      def initialize(options:, prompt: false, **)
        @options = options
        @prompt = prompt
        super(**)
      end

      attr_reader :options, :prompt
    end
  end
end
