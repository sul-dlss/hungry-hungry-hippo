# frozen_string_literal: true

module Edit
  module TabForm
    # Next button to progress through tabbed form
    class NextButtonComponent < ApplicationComponent
      def initialize(tab_id:, classes: [])
        @tab_id = tab_id
        @classes = classes
        super()
      end

      def data
        {
          controller: 'tab-nav',
          tab_nav_tab_id_value: @tab_id,
          action: 'click->tab-nav#showNext'
        }
      end

      attr_reader :classes
    end
  end
end
