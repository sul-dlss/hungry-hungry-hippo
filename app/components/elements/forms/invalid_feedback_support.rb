# frozen_string_literal: true

module Elements
  module Forms
    # Methods to support invalid feedback for form fields.
    class InvalidFeedbackSupport
      def self.id_for(field_name:, form:)
        form.field_id(field_name, 'error')
      end

      def self.arias_for(field_name:, form:)
        return {} if field_name.nil? || form.object&.errors&.[](field_name).blank?

        {
          invalid: true,
          describedby: id_for(field_name:, form:)
        }
      end
    end
  end
end
