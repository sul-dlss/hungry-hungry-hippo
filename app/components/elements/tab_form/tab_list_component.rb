# frozen_string_literal: true

module Elements
  module TabForm
    # Component for rendering tabbed navigation for the provided form.
    class TabListComponent < ApplicationComponent
      renders_many :tabs, 'Elements::TabForm::TabComponent'
      renders_many :panes, 'Elements::TabForm::PaneComponent'

      def initialize(model:, hidden_fields: [], classes: [])
        @classes = classes
        @model = model
        @hidden_fields = hidden_fields
        super()
      end

      attr_reader :model, :hidden_fields

      def classes
        # Provides d-flex, tabbable-panes as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[row tabbable-panes gx-4 gy-4 mb-5], @classes)
      end

      def render?
        tabs? && panes?
      end
    end
  end
end
