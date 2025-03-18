# frozen_string_literal: true

module Edit
  # Component for rendering a form label outside of a form field.
  class LabelComponent < ApplicationComponent
    def initialize(label_text:, hidden_label: false, classes: [], required: false)
      @label_text = label_text
      @hidden_label = hidden_label
      @classes = classes
      @required = required
      super()
    end

    attr_reader :required

    def classes
      merge_classes(%w[form-label fw-bold], @hidden_label ? 'visually-hidden' : nil, @classes)
    end
  end
end
