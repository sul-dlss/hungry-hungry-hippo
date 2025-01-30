# frozen_string_literal: true

module Elements
  module TabForm
    # Component for rendering tabbed navigation for the provided form.
    class TabListComponent < ApplicationComponent
      renders_many :tabs, 'Elements::TabForm::TabComponent'
      # The reason for the before_form_panes is to
      # avoid nested form tags, which aren't allowed in HTML.
      # Note that to reference the main form from elements in the before_form_pane,
      # provide a form_id to this component.
      # The form_id can then be provided as the form attribute to an input element to
      # connect it to the main form.
      # This approach is used to allow submit buttons to be outside the main form.
      renders_many :before_form_panes, 'Elements::TabForm::PaneComponent'
      renders_many :panes, 'Elements::TabForm::PaneComponent'

      def initialize(model:, form_id: nil, hidden_fields: [], classes: [])
        @classes = classes
        @form_id = form_id
        @model = model
        @hidden_fields = hidden_fields
        super()
      end

      attr_reader :model, :hidden_fields, :form_id

      def classes
        # Provides d-flex, tabbable-panes as the static default classes
        # merged with any additional classes passed in.
        merge_classes(%w[row tabbable-panes gx-4 gy-4 mb-5], @classes)
      end
    end
  end
end
