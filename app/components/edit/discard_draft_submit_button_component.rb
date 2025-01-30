# frozen_string_literal: true

module Edit
  # Renders a submit button for discarding a draft.
  # This is just the submit button; it does not include the form.
  # The reason for this is to allow the form to be separated from its submit button.
  # See DiscardDraftFormComponent for the form.
  # See DiscardDraftButtonComponent for the form and button together.
  # Provide a form_id for the form to use this unnested from the form.
  class DiscardDraftSubmitButtonComponent < Elements::Forms::SubmitComponent
    def initialize(form_id: nil, **args)
      args[:label] = 'Discard draft'
      args[:variant] = 'outline-primary'
      super
    end
  end
end
