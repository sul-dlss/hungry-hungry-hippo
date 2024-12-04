# frozen_string_literal: true

module Elements
  module Forms
    # Component for form day of the month fields
    # Note that this uses select_day, which is not called on a form builder instance.
    # Thus, some of the machinery of the form builder is provided below.
    class SelectDayFieldComponent < FieldComponent
      def value
        form.object.public_send(field_name)
      end

      # Prefix for the field name, e.g., work[publication_date_attributes]
      def prefix
        form.object_name
      end

      def classes
        merge_classes('form-select', form.object.errors[field_name].present? ? 'is-invalid' : nil)
      end
    end
  end
end
