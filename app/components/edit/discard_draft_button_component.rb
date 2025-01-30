# frozen_string_literal: true

module Edit
  # Component for a button to discard a draft.
  # This includes the form and the submit button.
  class DiscardDraftButtonComponent < ApplicationComponent
    def initialize(presenter:, classes: [])
      @presenter = presenter
      @classes = classes
      super()
    end

    attr_reader :presenter, :classes

    def render?
      presenter.discardable?
    end
  end
end
