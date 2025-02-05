# frozen_string_literal: true

module Elements
  # Renders a modal dialog
  class ModalComponent < ApplicationComponent
    renders_one :header # optional
    renders_one :footer # optional
    renders_one :body

    def initialize(id:, size: :lg)
      @id = id
      @size = size
      super()
    end

    attr_reader :id

    def classes
      merge_classes('modal', @size ? "modal-#{@size}" : nil)
    end
  end
end
