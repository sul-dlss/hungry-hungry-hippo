# frozen_string_literal: true

module Edit
  # Component for a button to discard a draft
  class DiscardDraftButtonComponent < Elements::ButtonFormComponent
    def initialize(presenter:, **args)
      @presenter = presenter
      args[:label] = 'Discard draft'
      args[:variant] = 'outline-primary'
      args[:confirm] = 'Are you sure?'
      args[:method] = :delete
      # polymorphic_path cannot be used in initializer, so overrriding link below
      args[:link] = nil
      super(**args)
    end

    def link
      polymorphic_path(@presenter)
    end

    def render?
      @presenter.discardable?
    end
  end
end
