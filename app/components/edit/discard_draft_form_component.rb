# frozen_string_literal: true

module Edit
  # Renders a form for discarding a draft.
  # The reason for this is to allow the form to be separated from its submit button.
  # The submit button is connected by the form attribute.
  # For a combined form and submit button, see DiscardDraftButtonComponent.
  # For a submit button to be used with this form, see DiscardDraftSubmitButtonComponent.
  class DiscardDraftFormComponent < ApplicationComponent
    def initialize(presenter:, id: nil)
      @presenter = presenter
      @id = id
      super()
    end

    def call
      form_with(url:, method: :delete, data:, id:) do
        content
      end
    end

    attr_reader :presenter, :id

    def url
      polymorphic_path(presenter)
    end

    def render?
      presenter.discardable?
    end

    def data
      {
        turbo_frame: '_top',
        turbo_confirm: 'Are you sure you want to delete this draft? It cannot be undone.'
      }
    end
  end
end
