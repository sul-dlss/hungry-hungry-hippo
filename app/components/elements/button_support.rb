# frozen_string_literal: true

module Elements
  # General support for buttons.
  class ButtonSupport
    def self.classes(variant: nil, size: nil, classes: [])
      ComponentSupport::CssClasses.merge('btn',
                                         variant ? "btn-#{variant}" : nil,
                                         size ? "btn-#{size}" : nil,
                                         classes)
    end
  end
end
