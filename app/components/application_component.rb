# frozen_string_literal: true

# Base component for all components in the application.
class ApplicationComponent < ViewComponent::Base
  # Merge classes together.
  #
  # @param args [Array<String>, String] The classes to merge (array, classes, space separated classes).
  # @return [String] The merged classes.
  def merge_classes(*)
    ComponentSupport::CssClasses.merge(*)
  end

  # Merge data-actions together.
  #
  # @param args [Array<String>, String] The actions to merge (array, classes, space separated classes).
  # @return [String] The merged classes.
  def merge_actions(*)
    ComponentSupport::CssClasses.merge(*)
  end

  def mark_label_required(label:, mark_required: false, hidden_label: 'required')
    label.to_s.dup.tap do |label_text|
      if mark_required
        label_text << "&nbsp;<span class=\"required\">*</span><span class=\"visually-hidden\"> (#{hidden_label})</span>".html_safe # rubocop:disable Rails/OutputSafety, Layout/LineLength
      end
    end.html_safe # rubocop:disable Rails/OutputSafety
  end
end
