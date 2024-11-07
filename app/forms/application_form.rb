# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks # before_validation, after_validation

  FORM_CLASS_SUFFIX = 'Form'

  def self.model_name
    # Remove the "Form" suffix from the class name.
    # This allows Rails magic such as route paths.
    ActiveModel::Name.new(self, nil, to_s.delete_suffix(FORM_CLASS_SUFFIX))
  end
end
