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

  # @param deposit [Boolean] whether the form is being used for a deposit
  def valid?(deposit: false)
    @deposit = deposit
    super()
  end

  # This can be used to control validations specific to deposits.
  # For example: validates :authors, presence: { message: 'requires at least one author' }, if: :deposit?
  def deposit?
    @deposit
  end
end
