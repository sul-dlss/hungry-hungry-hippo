# frozen_string_literal: true

module Elements
  # Component for a move down button
  class MoveDownButtonComponent < IconButtonComponent
    def initialize(**args)
      args[:classes] = merge_classes('move-down', args[:classes])
      super(icon: :move_down, label: 'Move down', **args)
    end
  end
end
