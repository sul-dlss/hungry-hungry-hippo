# frozen_string_literal: true

module Elements
  module Tabs
    # Component for rendering a list of tabs in a tabbed interface.
    class TabListComponent < ApplicationComponent
      renders_one :header # optional
      renders_many :tabs, Elements::Tabs::TabComponent
      renders_many :panes, Elements::Tabs::PaneComponent

      def initialize(classes: [])
        @classes = classes
        super()
      end

      def classes
        merge_classes('nav', @classes)
      end
    end
  end
end
