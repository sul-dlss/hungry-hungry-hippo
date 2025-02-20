# frozen_string_literal: true

module Elements
  module Tabs
    # Component for rendering a tab in a tabbed interface.
    class TabComponent < ApplicationComponent
      def initialize(label:, id:, pane_id:, active: false)
        @label = label
        @id = id
        @pane_id = pane_id
        @active = active
        super()
      end

      attr_reader :label, :id, :pane_id

      def active?
        @active
      end

      def button_classes
        merge_classes('nav-link', active? ? 'active' : nil)
      end
    end
  end
end
