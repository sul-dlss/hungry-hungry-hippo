# frozen_string_literal: true

module Articles
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:, license_presenter:)
        @form = form
        @license_presenter = license_presenter
        super()
      end

      attr_reader :form

      delegate :required_license_option?, to: :@license_presenter

      def field_name
        :license
      end

      def label
        helpers.t('license.edit.fields.label')
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
