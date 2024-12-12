# frozen_string_literal: true

module Elements
  module Forms
    # Component for form select fields
    class SelectFieldComponent < FieldComponent
      def initialize(options:, prompt: nil, **args)
        @options = options
        @prompt = prompt
        super(**args)
      end

      attr_reader :options, :prompt
    end
  end
end
