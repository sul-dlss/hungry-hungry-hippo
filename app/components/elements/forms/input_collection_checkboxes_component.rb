# frozen_string_literal: true

module Elements
  module Forms
    # Component for a set of checkboxes for a collection of objects
    # See https://api.rubyonrails.org/v8.0.0/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_checkboxes
    class InputCollectionCheckboxesComponent < BaseInputCollectionComponent
      def initialize(disabled_values: [], **args)
        @disabled_values = disabled_values
        super(**args)
      end

      attr_reader :disabled_values
    end
  end
end
