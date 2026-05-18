# frozen_string_literal: true

# The base class for all form classes
class ApplicationForm < Blanks::Base
  class << self
    # Override in subclasses if needed, e.g., to prevent the 'druid' param from being permitted
    def immutable_attributes
      []
    end

    # Use in controllers to validate expected parameters for forms
    def permitted_params
      params = user_editable_attributes
      nested = nested_attributes
      nested.present? ? params + [nested] : params
    end

    # Mirror ActiveRecord-style nested keys for strong params.
    def nested_attributes
      associations.transform_keys { |association_name| :"#{association_name}_attributes" }
                  .transform_values { {} }
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

  # @return [Array<String>] a list of validation errors for this form and any nested forms.
  #   The errors are formatted as "<model name> <attribute>: <error_type>".
  #   This method is primarily intended for reporting validation errors to Ahoy.
  def loggable_errors
    errors.map { |error| "#{model_name} #{error.attribute}: #{error.type}" }
  end

  # Used for looking up locales.
  def locales_key
    "#{self.class.model_name.param_key}_form"
  end
end
