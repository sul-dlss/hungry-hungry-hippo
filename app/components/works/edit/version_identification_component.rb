# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the article version identification field.
    class VersionIdentificationComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def call
        render Elements::Forms::SelectFieldComponent
          .new(form:,
               field_name: :article_version_identification,
               options: BaseWorkForm::ARTICLE_VERSION_IDENTIFICATION_OPTIONS,
               label: I18n.t('article_form.fields.version_identification.label'),
               tooltip: I18n.t('article_form.fields.version_identification.tooltip_html'),
               width: 500,
               label_classes: 'fw-bold',
               mark_required: true,
               prompt: 'Select...',
               container_classes: 'mb-4')
      end
    end
  end
end
