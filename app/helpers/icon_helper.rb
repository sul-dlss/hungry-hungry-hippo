# frozen_string_literal: true

# Helper for rendering icons.
module IconHelper
  extend ActionView::Helpers::TagHelper

  def icon(icon_classes:, classes: nil, **)
    all_classes = [icon_classes, classes].compact.join(' ')
    content_tag(:i, nil, class: all_classes, **)
  end

  def right_arrow_icon(**)
    icon(icon_classes: 'bi bi-arrow-right', **)
  end

  def danger_icon(**)
    icon(icon_classes: 'bi bi-exclamation-triangle-fill', **)
  end

  def note_icon(**)
    icon(icon_classes: 'bi bi-exclamation-circle-fill', **)
  end

  def plus_icon(**)
    icon(icon_classes: 'bi bi-plus', **)
  end

  def success_icon(**)
    icon(icon_classes: 'bi bi-check-circle-fill', **)
  end

  def info_icon(**)
    icon(icon_classes: 'bi bi-info-circle-fill', **)
  end

  def warning_icon(**)
    icon(icon_classes: 'bi bi-exclamation-triangle-fill', **)
  end
end
