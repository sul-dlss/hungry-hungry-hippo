# frozen_string_literal: true

module Works
  module Edit
    # Component for the abstract pane on the edit form.
    class AbstractComponent < ApplicationComponent
      def initialize(form:, mark_abstract_required: true, mark_keywords_required: true)
        @form = form
        @mark_abstract_required = mark_abstract_required
        @mark_keywords_required = mark_keywords_required
        super()
      end

      attr_reader :form, :mark_abstract_required, :mark_keywords_required

      def keywords_label
        I18n.t('work_form.nested_forms.keywords.legend').dup.tap do |text|
          text << ' (at least one is required)' if mark_keywords_required
        end
      end
    end
  end
end
