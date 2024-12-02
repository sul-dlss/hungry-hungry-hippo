# frozen_string_literal: true

module Elements
  module TabForm
    # Next button to progress through tabbed form
    class NextButtonComponent < ButtonComponent
      def initialize(tab_id:)
        super(label: 'Next',
              variant: :primary,
              classes: 'ms-2',
              data: {
                controller: 'tab-next',
                tab_next_selector_value: tab_id,
                action: 'click->tab-next#show'
              }
              )
      end
    end
  end
end
