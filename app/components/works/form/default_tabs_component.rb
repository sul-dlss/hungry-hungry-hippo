# frozen_string_literal: true

module Works
  module Form
    # Component for rendering the default set of tabs and panes for a work form.
    class DefaultTabsComponent < ApplicationComponent
      def initialize(component:, active_tab_name:)
        @component = component
        @active_tab_name = active_tab_name
        super()
      end

      attr_reader :component, :active_tab_name
    end
  end
end
