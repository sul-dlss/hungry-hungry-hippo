# frozen_string_literal: true

module Edit
  # Component for a pencil icon button to edit a draft
  class EditIconButtonComponent < Elements::IconButtonLinkComponent
    def initialize(presenter:, icon_classes:, **args)
      @presenter = presenter
      @icon_classes = icon_classes
      # polymorphic_path cannot be used in initializer, so overrriding link below
      args[:link] = nil
      super(icon: :edit, label: 'Edit', icon_classes:, **args)
    end

    def link
      edit_polymorphic_path(@presenter)
    end

    def render?
      @presenter.editable?
    end
  end
end
