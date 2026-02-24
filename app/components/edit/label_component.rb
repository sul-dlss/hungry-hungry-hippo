# frozen_string_literal: true

module Edit
  # Component for rendering a form label outside of a form field.
  class LabelComponent < ApplicationComponent
    def initialize(label_text:, hidden_label: false, classes: [], mark_required: false)
      @label_text = label_text
      @hidden_label = hidden_label
      @classes = classes
      @mark_required = mark_required
      super()
    end

    def call
      tag.label(label_text, class: classes)
    end

    def label_text
      mark_label_required(label: @label_text, mark_required: @mark_required)
    end

    def classes
      merge_classes(%w[form-label fw-bold], @hidden_label ? 'visually-hidden' : nil, @classes)
    end
  end
end
