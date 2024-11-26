# frozen_string_literal: true

module Elements
  module Layout
    # Component for rendering tabbed navigation for the provided form.
    class TabbedFormComponent < ApplicationComponent
      renders_many :tabs, 'Elements::Layout::TabComponent'
      renders_one :work_form, 'Works::Edit::FormComponent'

      def initialize(orientation: 'vertical', classes: [], tab_classes: [])
        @orientation = orientation
        @classes = classes
        @tab_classes = tab_classes
        super()
      end

      attr_reader :orientation

      def classes
        # Provides d-flex, tabbable-panes as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[d-flex tabbable-panes], @classes)
      end

      def tab_classes
        merge_classes(%w[nav nav-pills flex-column px-2 py-1 me-5 col-3], @tab_classes)
      end

      def render?
        tabs?
      end
    end
  end
end
