# frozen_string_literal: true

# The base class for all form classes
class ApplicationForm
  include ActiveModel::NestedAttributes

  class << self
    FORM_CLASS_SUFFIX = 'Form'

    # Remove the "Form" suffix from the class name. This allows Rails magic such
    # as route paths.
    def model_name
      ActiveModel::Name.new(self, nil, to_s.delete_suffix(FORM_CLASS_SUFFIX))
    end

    # Override in subclasses if needed, e.g., to prevent the 'druid' param from being permitted
    def immutable_attributes
      []
    end

    # Use in controllers to validate expected parameters for forms
    def permitted_params
      user_editable_attributes.tap do |attrs|
        attrs << nested_attributes if defined?(nested_attributes)
      end
    end

    private

    def user_editable_attributes
      (attribute_names.map(&:to_sym) - immutable_attributes.map(&:to_sym)).map do |attribute_name|
        # Could not find a way to determine when attribute is an array.
        # This approach is based on the assumption that every attribute will
        # have a type EXCEPT for arrays.
        type_for_attribute(attribute_name).type.nil? ? { attribute_name => [] } : attribute_name
      end
    end
  end

  # NOTE: Override in subclasses if needed, e.g., to change when a form is considered empty
  def empty?
    attributes.all? { |_name, value| value.blank? }
  end

  # @return [Array<String>] a list of validation errors for this form and any nested forms.
  #   The errors are formatted as "<model name> <attribute>: <error_type>".
  #   This method is primarily intended for reporting validation errors to Ahoy.
  def loggable_errors
    errors.map { |error| "#{model_name} #{error.attribute}: #{error.type}" }
  end
end
