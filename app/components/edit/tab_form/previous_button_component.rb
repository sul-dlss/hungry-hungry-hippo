# frozen_string_literal: true

module Edit
  module TabForm
    # Previous button to progress through tabbed form
    class PreviousButtonComponent < ApplicationComponent
      def initialize(tab_id:, classes: [])
        @tab_id = tab_id
        @classes = classes
        super()
      end

      def call
        render SdrViewComponents::Elements::ButtonComponent.new(label: 'Previous', variant: :'outline-primary', data:,
                                                                classes: @classes)
      end

      def data
        {
          controller: 'tab-nav',
          tab_nav_tab_id_value: @tab_id,
          action: 'click->tab-nav#showPrevious'
        }
      end
    end
  end
end
