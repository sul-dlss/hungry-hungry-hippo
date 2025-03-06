# frozen_string_literal: true

module Collections
  module Edit
    # Component for adding multiple participants to a collection
    class BulkParticipantsComponent < ApplicationComponent
      def initialize(form:, field_name:, model_class:)
        @form = form
        @field_name = field_name
        @model_class = model_class
        super()
      end

      attr_reader :form, :field_name, :model_class

      def data
        {
          controller: 'participants',
          participants_url_value: '/accounts/search',
          participants_nested_form_outlet: "##{fieldset_id}"
        }
      end

      def fieldset_id
        "#{field_name}-fieldset"
      end

      def add_button_label
        "Add #{model_class.model_name.plural.humanize(capitalize: false)}"
      end

      def textarea_id
        "#{field_name}-textarea"
      end
    end
  end
end
