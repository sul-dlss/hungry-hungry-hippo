# frozen_string_literal: true

module Elements
  module TabForm
    # Component for rendering tabbed navigation for the provided form.
    class TabListComponent < ApplicationComponent
      renders_many :tabs, 'Elements::TabForm::TabComponent'
      # The reason for the before_form_panes, panes, and after_form_panes is to
      # avoid nested form tags, which aren't allowed in HTML.
      # Note that to reference a form from outside the form, provide the form id as the form attribute.
      # This approach is used to allow submit buttons to be outside the form.
      renders_many :before_form_panes, 'Elements::TabForm::PaneComponent'
      renders_many :panes, 'Elements::TabForm::PaneComponent'
      renders_many :after_form_panes, 'Elements::TabForm::PaneComponent'

      def initialize(model:, form_id:, hidden_fields: [], classes: [])
        @classes = classes
        @model = model
        @hidden_fields = hidden_fields
        @form_id = form_id
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
