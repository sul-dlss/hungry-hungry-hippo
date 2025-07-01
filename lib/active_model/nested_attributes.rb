# frozen_string_literal: true

require 'active_support/concern'

module ActiveModel
  # Mimic ActiveRecord::NestedAttributes for ActiveModel objects
  module NestedAttributes
    extend ActiveSupport::Concern

    include ActiveModel::Attributes
    include ActiveModel::Serialization

    class_methods do
      def accepts_nested_attributes_for(*models, **options)
        validate_options!(options)

        models.each do |model|
          repeatable = determine_repeatability_of(model)
          define_attribute_types_for(model, repeatable)
          define_attributes_for(model, repeatable)
          define_getters_for(model)
        end

        allow_reflection_on(models)
        define_validation_for(models)
      end

      private

      def validate_options!(options)
        opts = { allow_destroy: true }.merge(options)
        opts.assert_valid_keys(:allow_destroy)
      end

      def determine_repeatability_of(model) # rubocop:disable Naming/PredicateMethod
        model.to_s.pluralize == model.to_s
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def define_attribute_types_for(model, repeatable)
        return if const_defined?(model.to_s.classify.concat('Type'))

        # For a :related_links attr, define a custom RelatedLinksType to be used in the `attribute` call below
        const_set(
          model.to_s.classify.concat('Type'),
          Class.new(ActiveModel::Type::Value) do
            # Defining `#cast` on an ActiveModel type tells it how to deserialize,
            # e.g., from a hash or an array of hashes to RelatedLinkForm instances
            define_method(:cast) do |attributes_hash_or_list|
              form_class = model.to_s.classify.concat('Form').constantize

              if repeatable
                # The key in `attributes_hash_or_list`, if a hash, is a throw-away ID, so ignore it.
                Array.wrap(attributes_hash_or_list.try(:values) || attributes_hash_or_list || {}).map do |attributes|
                  # This chain of operations converts nested attributes symbols to related form classes,
                  # e.g., :related_links => RelatedLinkForm
                  # attributes may already be a form class instance, e.g., when multiple layers of nested attributes.
                  attributes.is_a?(Hash) ? form_class.new(**attributes) : attributes
                end
              else
                form_class.new(**(attributes_hash_or_list || {}))
              end
            end
          end
        )
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def define_attributes_for(model, repeatable)
        type_class = model.to_s.classify.concat('Type')
        if repeatable
          attribute :"#{model}_attributes", const_get(type_class).new, array: true, default: -> { [{}] }
        else
          attribute :"#{model}_attributes", const_get(type_class).new, default: -> { {} }
        end
      end

      def define_getters_for(model)
        # Each nested attribute needs a getter for the form helper to recognize it as a nested attribute
        define_method(:"#{model}") do
          # Return the attribute set up immediately above
          public_send(:"#{model}_attributes")
        end
      end

      def define_validation_for(models)
        define_method(:valid?) do |*args, **kwargs, &block|
          self_valid = super(*args, **kwargs, &block)

          # Call valid? on each nested model, and return true if all are valid
          nested_valid = models.flat_map do |model_name|
            Array(public_send(model_name)).map { |nested_model| nested_model.valid?(*args, **kwargs, &block) }
          end.all?

          self_valid && nested_valid
        end
      end

      def allow_reflection_on(models)
        # Allow reflection on all the nested attributes within a class. This defines
        # a method on the form class itself that reduces copypasta in other places, e.g.,
        # param validation in controllers.
        singleton_class.define_method(:nested_attributes) do
          models.to_h { |model| [:"#{model}_attributes", {}] }
        end
      end
    end
  end
end
