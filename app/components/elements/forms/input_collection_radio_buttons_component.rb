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
    end
  end
end
