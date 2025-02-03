# frozen_string_literal: true

module Edit
  # Component for a button to edit a draft
  class EditDraftButtonComponent < Elements::ButtonLinkComponent
    def initialize(presenter:, **args)
      @presenter = presenter
      args[:label] ||= 'Edit or deposit'
      args[:variant] = 'outline-primary'
      # polymorphic_path cannot be used in initializer, so overrriding link below
      args[:link] = nil
      super(**args)
    end

    def link
      edit_polymorphic_path(@presenter)
    end

    def render?
      @presenter.editable?
    end
  end
end
