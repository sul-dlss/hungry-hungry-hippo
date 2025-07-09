# frozen_string_literal: true

module Elements
  # Component for a delete button
  class DeleteButtonComponent < IconButtonComponent
    def initialize(label: 'Clear', **args)
      super(icon: :delete, label:, classes: Array(classes) + ['px-0'], **args)
    end
  end
end
