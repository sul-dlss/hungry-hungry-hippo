# frozen_string_literal: true

module Edit
  module TabForm
    # Renders the one real <form> tag backing a TabListComponent-based tabbed form.
    # Contains only hidden fields -- the tabbed form's visible fields associate with this
    # form via the `form` HTML attribute (see TabbedFormBuilder), not DOM nesting.
    class HiddenFieldsFormComponent < ApplicationComponent
      def initialize(model:, id:, hidden_fields: [])
        @model = model
        @id = id
        @hidden_fields = hidden_fields
        super()
      end

      attr_reader :model, :id, :hidden_fields
    end
  end
end
