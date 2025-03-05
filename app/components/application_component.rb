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

  # Generate error field ID for a form and field name
  #
  # @param field_name [Symbol,String] The name of the field needing an error field
  # @param form [ActiveModel::Model] An ActiveModel form instance
  # @return [String] A field identifier
  def invalid_feedback_id_for(field_name:, form:)
    form.field_id(field_name, 'error')
  end

  # Generate ARIA hash for a form and field name
  #
  # @param field_name [Symbol,String] The name of the field needing an error field
  # @param form [ActiveModel::Model] An ActiveModel form instance
  # @return [Hash] A hash of ARIA attributes
  def invalid_feedback_arias_for(field_name:, form:)
    return {} if field_name.nil? || form.object&.errors&.[](field_name).blank?

    {
      invalid: true,
      describedby: invalid_feedback_id_for(field_name:, form:)
    }
  end
end
