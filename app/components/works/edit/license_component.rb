# frozen_string_literal: true

module Works
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def field_name
        :license
      end

      def label
        helpers.t('license.edit.fields.label')
      end

      def help_text
        helpers.t('works.edit.fields.license.help_text')
      end

      def license_options
        WorkForm.licenses.values.map { |license| [license['label'], license['uri']] }
      end

      def prompt
        'Select...'
      end
    end
  end
end
