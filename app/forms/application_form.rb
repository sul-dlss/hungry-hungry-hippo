# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks # before_validation, after_validation

  def self.model_name
    # Remove the "Form" suffix from the class name.
    # This allows Rails magic such as route paths.
    model_name = method(:model_name).super_method.call.to_s
    ActiveModel::Name.new(self, nil, model_name.delete_suffix('Form'))
  end
end
