# frozen_string_literal: true

module Edit
  # Component for rendering a tabless form for the provided model.
  class TablessFormComponent < ApplicationComponent
    # The reason for the before_form_section is to
    # avoid nested form tags, which aren't allowed in HTML.
    # Note that to reference the main form from elements in the before_form_section,
    # provide a form_id to this component.
    # The form_id can then be provided as the form attribute to an input element to
    # connect it to the main form.
    # This approach is used to allow submit buttons to be outside the main form.
    renders_one :before_form_section
    renders_one :form_section

    def initialize(model:, form_id: nil)
      @model = model
      @form_id = form_id
      super()
    end

    attr_reader :model, :form_id
  end
end
