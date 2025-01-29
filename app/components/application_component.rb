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
end
