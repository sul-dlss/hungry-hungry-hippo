# frozen_string_literal: true

module Elements
  # Component for a delete button
  class DeleteButtonComponent < IconButtonComponent
    def initialize(**args)
      super(icon: :delete, label: 'Clear', **args)
    end
  end
end
