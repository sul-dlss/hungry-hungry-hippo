# frozen_string_literal: true

module Works
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:, license_presenter:, license_help_url: Settings.license_url, show_terms_of_use: true, # rubocop:disable Metrics/ParameterLists
                     show_help_text: true, tooltip: nil)
        @form = form
        @license_presenter = license_presenter
        @license_help_url = license_help_url
        @show_terms_of_use = show_terms_of_use
        @show_help_text = show_help_text
        @tooltip = tooltip
        super()
      end

      attr_reader :form, :show_terms_of_use, :show_help_text, :license_help_url, :tooltip

      delegate :required_license_option?, to: :@license_presenter

      def field_name
        :license
      end

      def label
        helpers.t('work_form.fields.license.label')
      end

      def help_text
        show_help_text ? helpers.t('work_form.fields.license.help_text') : nil
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
