# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model # Include this one first!
  include ActiveModel::Attributes
  include ActiveModel::Serialization

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

  # NOTE: Options have NOT yet been implemented! (e.g., `allow_destroy`)
  def self.accepts_nested_attributes_for(*models, **_options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    # For each nested attribute, define a getter and a setter.
    models.each do |model|
      # Each nested attribute needs a getter for ActiveModel::Serialization to include it in its related model.
      define_method(:"#{model}") do
        # Default the instance variable to an empty array so we can append to it below.
        instance_variable_get(:"@#{model}") || []
      end

      # This is invoked by both the form submission, which supplies a hash argument with each key being a bogus ID,
      # or by the deposit job which uses ActiveModel::Serialization to automagically handle the nested
      # attribute, in which case it lacks the bogus IDs and is an array. We like the automagicks, so we
      # deal with both cases here.
      define_method(:"#{model}=") do |attributes_hash_or_list|
        # Default the instance variable to an empty array so we can append to it below.
        instance_variable_set(:"@#{model}", instance_variable_get(:"@#{model}") || [])

        # The key in `attributes_hash_or_list`, if a hash, is a throw-away ID, so ignore it.
        Array.wrap(attributes_hash_or_list.try(:values) || attributes_hash_or_list).each do |attributes|
          instance_variable_get(:"@#{model}").push(
            # This chain of operations converts nested attributes symbols to related form classes,
            # e.g., :related_links => RelatedLinkForm
            model.to_s.classify.concat(FORM_CLASS_SUFFIX).constantize.new(attributes)
          )
        end
      end
    end

    # Allow reflection on all the nested attributes within a class. This defines
    # a method on the form class itself that reduces copypasta in other places, e.g.,
    # param validation in controllers.
    singleton_class.define_method(:nested_attributes_hash) do
      models.index_with { {} }
    end

    # Allows serialization of the form using ActiveModel::Serialization
    define_method(:attributes) do
      # Keys *must* be strings
      super().merge(models.to_h { |attr| [attr.to_s, public_send(attr).map(&:attributes)] })
    end
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
