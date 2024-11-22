# frozen_string_literal: true

module Works
  module Edit
    # Next button to progress through tabbed form
    class NextButtonComponent < Elements::ButtonComponent
      def initialize(next_tab_id:)
        super(label: 'Next',
              variant: :primary,
              classes: 'ms-2',
              data: {
                controller: 'tab-next',
                tab_next_selector_value: next_tab_id,
                action: 'click->tab-next#show'
              }
              )
      end
    end
  end
end
