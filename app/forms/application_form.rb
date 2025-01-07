# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model # Include this one first!
  include ActiveModel::NestedAttributes

  FORM_CLASS_SUFFIX = 'Form'

  def self.model_name
    # Remove the "Form" suffix from the class name.
    # This allows Rails magic such as route paths.
    ActiveModel::Name.new(self, nil, to_s.delete_suffix(FORM_CLASS_SUFFIX))
  end

  def self.user_editable_attributes
    (attribute_names - immutable_attributes).map(&:to_sym)
  end

  def self.immutable_attributes
    []
  end
end
