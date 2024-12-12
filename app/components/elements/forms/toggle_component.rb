# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle-like radio button group field
    class ToggleComponent < FieldComponent
      renders_many :toggle_options, Elements::Forms::ToggleOptionComponent
    end
  end
end
