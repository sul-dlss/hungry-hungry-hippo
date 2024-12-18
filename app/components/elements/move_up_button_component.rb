# frozen_string_literal: true

module Elements
  # Component for a move up button
  class MoveUpButtonComponent < IconButtonComponent
    def initialize(**args)
      args[:classes] = merge_classes('move-up', args[:classes])
      super(icon: :move_up, label: 'Move up', **args)
    end
  end
end
