# frozen_string_literal: true

module Edit
  module TabForm
    # Component for rendering tabbed navigation for the provided form.
    class TabListComponent < ApplicationComponent
      renders_many :tabs, Edit::TabForm::TabComponent
      renders_many :panes

      def initialize(classes: [], data: {})
        @classes = classes
        @data = data
        super()
      end

      def classes
        # Provides d-flex, tabbable-panes as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[tab-error row tabbable-panes gx-4 gy-4 mb-5], @classes)
      end

      # `change` events fired by fields anywhere in the panes bubble up to this
      # component's root element (fields are associated with the real form via the
      # `form` attribute, not DOM nesting, so actions can't live on the `<form>` tag itself).
      def data
        @data.merge(controller: 'tab-error')
      end
    end
  end
end
