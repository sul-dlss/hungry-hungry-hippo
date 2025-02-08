# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model # Include this one first!
  include ActiveModel::NestedAttributes
  include ActiveModel::Validations::Callbacks

  FORM_CLASS_SUFFIX = 'Form'

  def self.model_name
    # Remove the "Form" suffix from the class name.
    # This allows Rails magic such as route paths.
    ActiveModel::Name.new(self, nil, to_s.delete_suffix(FORM_CLASS_SUFFIX))
  end

  def self.user_editable_attributes
    (attribute_names.map(&:to_sym) - immutable_attributes.map(&:to_sym)).map do |attribute_name|
      # Could not find a way to determine when attribute is an array.
      # This approach is based on the assumption that every attribute will
      # have a type EXCEPT for arrays.
      type_for_attribute(attribute_name).type.nil? ? { attribute_name => [] } : attribute_name
    end
  end

  def self.immutable_attributes
    []
  end
end
