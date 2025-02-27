# frozen_string_literal: true

module Edit
  # Renders a submit button for discarding a draft.
  # This is just the submit button; it does not include the form.
  # The reason for this is to allow the form to be separated from its submit button.
  # See DiscardDraftFormComponent for the form.
  # See DiscardDraftButtonComponent for the form and button together.
  # Provide a form_id for the form to use this unnested from the form.
  class DiscardDraftSubmitButtonComponent < ApplicationComponent
    def initialize(presenter:, **btn_args)
      @presenter = presenter
      @btn_args = btn_args
      super
    end

    def render?
      @presenter&.discardable?
    end

    def label
      'Discard draft'
    end

    attr_reader :btn_args
  end
end
