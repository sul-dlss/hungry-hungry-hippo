# frozen_string_literal: true

module Elements
  module Forms
    # Component for a set of radio buttons for a collection of objects
    # See https://api.rubyonrails.org/v8.0.0/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_radio_buttons
    class InputCollectionRadioButtonsComponent < BaseInputCollectionComponent
      def initialize(disabled: false, **args)
        @disabled = disabled
        super(**args)
      end

      attr_reader :disabled

      def input_options(builder)
        { class: 'form-check-input', id: blank_value_id(builder), data: input_data, disabled:,
          aria: { required: @mark_required }, form: form.id }.compact
      end

      def label_options(builder)
        { class: 'form-check-label', for: blank_value_id(builder) }.compact
      end

      private

      # Rails 8.1.4 omits the trailing underscore from the label's `for` but still appends it to the
      # input id when a collection value is blank, leaving the label associated with nothing.
      # Setting one explicit id keeps both sides in sync. See https://github.com/rails/rails/pull/57940
      # The hashes above are compacted because Rails skips generating a default when a key is present
      # but nil, which would strip the id and `for` from every other option.
      def blank_value_id(builder)
        form.field_id(field_name, 'none') if builder.value.blank?
      end
    end
  end
end
