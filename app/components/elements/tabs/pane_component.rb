# frozen_string_literal: true

module Elements
  module Tabs
    # Component for rendering a tab pane in a tabbed interface.
    class PaneComponent < ApplicationComponent
      def initialize(id:, tab_id:, active: false)
        @id = id
        @tab_id = tab_id
        @active = active
        super()
      end

      attr_reader :id, :tab_id

      def active?
        @active
      end

      def classes
        merge_classes(%w[tab-pane fade], active? ? %w[show active] : nil)
      end
    end
  end
end
