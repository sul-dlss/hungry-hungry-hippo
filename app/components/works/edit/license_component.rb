# frozen_string_literal: true

module Works
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:, license_presenter:, license_help_url: Settings.license_url, show_terms_of_use: true)
        @form = form
        @license_presenter = license_presenter
        @license_help_url = license_help_url
        @show_terms_of_use = show_terms_of_use
        super()
      end

      attr_reader :form, :show_terms_of_use, :license_help_url

      delegate :required_license_option?, to: :@license_presenter

      def field_name
        :license
      end

      def label
        helpers.t('work_form.fields.license.label')
      end

      def help_text
        helpers.t('work_form.fields.license.help_text')
      end

      def tooltip
        helpers.t('work_form.fields.license.tooltip_html')
      end

      def license_options
        @license_presenter.options
      end

      def license_label
        @license_presenter.label
      end
    end
  end
end
