# frozen_string_literal: true

module Edit
  # Component for a pencil icon button to edit a draft
  class EditIconButtonComponent < Elements::IconButtonLinkComponent
    def initialize(presenter:, tab: nil, **args)
      @presenter = presenter
      @tab = tab
      # polymorphic_path cannot be used in initializer, so overrriding link below
      args[:link] = nil
      args[:data] = { turbo_frame: '_top', turbo_preserve_scroll: false }
      super(icon: :edit, label: 'Edit', **args)
    end

    def link
      edit_polymorphic_path(@presenter, tab: @tab)
    end

    def render?
      @presenter&.editable?
    end
  end
end
