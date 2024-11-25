# frozen_string_literal: true

module Works
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:, hidden_label: false, label: nil, help_text: nil)
        @form = form
        @hidden_label = hidden_label
        @label = label
        @help_text = help_text
        super()
      end

      attr_reader :form, :hidden_label, :label, :help_text

      def field_name
        :license
      end

      def license_options
        [['CC-BY-4.0 Attribution International', 'https://creativecommons.org/licenses/by/4.0/legalcode']]
      end

      def prompt
        'Select...'
      end
    end
  end
end
