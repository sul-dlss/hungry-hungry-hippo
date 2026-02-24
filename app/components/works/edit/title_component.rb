# frozen_string_literal: true

module Works
  module Edit
    # Component for the title pane on the edit form.
    class TitleComponent < ApplicationComponent
      def initialize(form:, work_form:)
        @form = form
        @work_form = work_form
        super()
      end

      attr_reader :form, :work_form

      delegate :works_contact_email, to: :work_form

      def contact_emails_label_text
        I18n.t('contact_emails.edit.legend').dup.tap do |text|
          text << ' (at least one is required)' unless works_contact_email?
        end
      end

      def works_contact_email?
        works_contact_email.present?
      end
    end
  end
end
