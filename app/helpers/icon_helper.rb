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

  def success_icon(**)
    icon(icon_classes: 'bi bi-check-circle-fill', **)
  end

  def info_icon(**)
    icon(icon_classes: 'bi bi-info-circle-fill', **)
  end

  def warning_icon(**)
    icon(icon_classes: 'bi bi-exclamation-triangle-fill', **)
  end

  def delete_icon(**)
    icon(icon_classes: 'bi bi-trash', **)
  end

  def edit_icon(**)
    icon(icon_classes: 'bi bi-pencil', **)
  end

  def first_icon(**)
    icon(icon_classes: 'bi bi-chevron-double-left', **)
  end

  def last_icon(**)
    icon(icon_classes: 'bi bi-chevron-double-right', **)
  end

  def next_icon(**)
    icon(icon_classes: 'bi bi-chevron-right', **)
  end

  def previous_icon(**)
    icon(icon_classes: 'bi bi-chevron-left', **)
  end

  def upload_icon(**)
    icon(icon_classes: 'bi bi-cloud-upload-fill', **)
  end

  def move_up_icon(**)
    icon(icon_classes: 'bi bi-arrow-up', **)
  end

  def move_down_icon(**)
    icon(icon_classes: 'bi bi-arrow-down', **)
  end

  def calendar_icon(**)
    icon(icon_classes: 'bi bi-calendar', **)
  end
end
