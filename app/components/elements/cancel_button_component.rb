# frozen_string_literal: true

module Elements
  # Component for a cancel button
  class CancelButtonComponent < ButtonLinkComponent
    def initialize(**args)
      args[:variant] = :link
      args[:label] = 'Cancel'
      super
    end
  end
end
