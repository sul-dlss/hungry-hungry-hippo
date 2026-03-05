# frozen_string_literal: true

module Works
  module Edit
    # Component for the title pane on the edit form.
    class TitleComponent < ApplicationComponent
      def initialize(form:, work_form:, mark_contact_emails_required: true)
        @form = form
        @work_form = work_form
        @mark_contact_emails_required = mark_contact_emails_required
        super()
      end

      attr_reader :form, :work_form

      delegate :works_contact_email, to: :work_form

      def contact_emails_label_text
        I18n.t('work_form.nested_forms.contact_emails.legend').dup.tap do |text|
          text << ' (at least one is required)' if mark_contact_emails_required?
        end
      end

      def works_contact_email?
        works_contact_email.present?
      end

      def mark_contact_emails_required?
        @mark_contact_emails_required && !works_contact_email?
      end
    end
  end
end
