# frozen_string_literal: true

require 'active_support/concern'

module ActiveModel
  # Mimic ActiveRecord::NestedAttributes for ActiveModel objects
  module NestedAttributes
    extend ActiveSupport::Concern

    include ActiveModel::Attributes
    include ActiveModel::Serialization

    class_methods do
      # NOTE: Options have NOT yet been implemented! (e.g., `allow_destroy`)
      def accepts_nested_attributes_for(*models, **_options)
        define_attribute_types_for(models)
        define_attributes_for(models)
        define_getters_for(models)
        define_validation_for(models)
        allow_reflection_on(models)
      end

      private

      def define_attribute_types_for(models) # rubocop:disable Metrics/AbcSize
        models.each do |model|
          next if const_defined?(model.to_s.classify.concat('Type'))

          # For a :related_links attr, define a custom RelatedLinksType to be used in the `attribute` call below
          const_set(
            model.to_s.classify.concat('Type'),
            Class.new(ActiveModel::Type::Value) do
              # Defining `#cast` on an ActiveModel type tells it how to deserialize,
              # e.g., from a hash or an array of hashes to RelatedLinkForm instances
              define_method(:cast) do |attributes_hash_or_list|
                # The key in `attributes_hash_or_list`, if a hash, is a throw-away ID, so ignore it.
                Array.wrap(attributes_hash_or_list.try(:values) || attributes_hash_or_list).map do |attributes|
                  # This chain of operations converts nested attributes symbols to related form classes,
                  # e.g., :related_links => RelatedLinkForm
                  model.to_s.classify.concat('Form').constantize.new(**attributes)
                end
              end
            end
          )
        end
      end

      def define_attributes_for(models)
        models.each do |model|
          attribute :"#{model}_attributes", const_get(model.to_s.classify.concat('Type')).new,
                    array: true, default: -> { [{}] }
        end
      end

      def define_getters_for(models)
        models.each do |model|
          # Each nested attribute needs a getter for the form helper to recognize it as a nested attribute
          define_method(:"#{model}") do
            # Return the attribute set up immediately above
            public_send(:"#{model}_attributes")
          end
        end
      end

      def define_validation_for(models)
        define_method(:valid?) do |*args, **kwargs, &block|
          self_valid = super(*args, **kwargs, &block)

          nested_valid = models.all? do |nested_model_name|
            public_send(nested_model_name).map { |nested_model| nested_model.valid?(*args, **kwargs, &block) }.all?
          end

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
