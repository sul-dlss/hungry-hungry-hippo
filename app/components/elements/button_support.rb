# frozen_string_literal: true

module Elements
  # General support for buttons.
  class ButtonSupport
    def self.classes(variant: nil, size: nil, classes: [], bordered: true)
      ComponentSupport::CssClasses.merge('btn',
                                         variant ? "btn-#{variant}" : nil,
                                         size ? "btn-#{size}" : nil,
                                         bordered ? nil : %w[border border-0],
                                         classes)
    end
  end
end
