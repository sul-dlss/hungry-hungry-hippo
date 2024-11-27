# frozen_string_literal: true

module Elements
  # Component for rendering tabbed navigation for the provided form.
  class TabListComponent < ApplicationComponent
    renders_many :tabs, 'Elements::TabComponent'
    renders_one :form

    def initialize(classes: [], tab_classes: [])
      @classes = classes
      @tab_classes = tab_classes
      super()
    end

    def classes
      # Provides d-flex, tabbable-panes as the static default classes
      # merged with any additional classes passed in.
      merge_classes(%w[d-flex tabbable-panes], @classes)
    end

    def tab_classes
      merge_classes(%w[nav nav-pills flex-column px-2 py-1 me-5 col-3], @tab_classes)
    end

    def render?
      tabs? && form?
    end
  end
end
