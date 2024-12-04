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
      def accepts_nested_attributes_for(*models, **options)
        validate_options!(options)
        define_attribute_types_for(models, options)
        define_attributes_for(models, options)
        define_getters_for(models)
        allow_reflection_on(models)
        define_validation
      end

      private

      def validate_options!(options)
        opts = { allow_destroy: true }.merge(options)
        opts.assert_valid_keys(:allow_destroy, :form_class, :array)
      end

      def define_attribute_types_for(models, options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        models.each do |model|
          next if const_defined?(model.to_s.classify.concat('Type'))

          # For a :related_links attr, define a custom RelatedLinksType to be used in the `attribute` call below
          const_set(
            (options[:form_class] || model).to_s.classify.concat('Type'),
            Class.new(ActiveModel::Type::Value) do
              # Defining `#cast` on an ActiveModel type tells it how to deserialize,
              # e.g., from a hash or an array of hashes to RelatedLinkForm instances
              define_method(:cast) do |attributes_hash_or_list|
                form_class = options[:form_class] || model.to_s.classify.concat('Form').constantize
                # The key in `attributes_hash_or_list`, if a hash, is a throw-away ID, so ignore it.
                if options.fetch(:array, true)
                  Array.wrap(attributes_hash_or_list.try(:values) || attributes_hash_or_list).map do |attributes|
                    # This chain of operations converts nested attributes symbols to related form classes,
                    # e.g., :related_links => RelatedLinkForm
                    form_class.new(**attributes)
                  end
                else
                  form_class.new(**(attributes_hash_or_list || {}))
                end
              end
            end
          )
        end
      end

      def define_attributes_for(models, options)
        models.each do |model|
          form_class = (options[:form_class] || model).to_s.classify.concat('Type')
          if options.fetch(:array, true)
            attribute :"#{model}_attributes", const_get(form_class).new,
                      array: true, default: -> { [{}] }
          else
            attribute :"#{model}_attributes", const_get(form_class).new,
                      default: -> { {} }
          end
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

      def define_validation
        define_method(:valid?) do |*args, **kwargs, &block|
          self_valid = super(*args, **kwargs, &block)
          # Call valid? on each nested model, and return true if all are valid
          nested_valid = self.class.nested_model_names.flat_map do |nested_model_name|
            Array(public_send(nested_model_name)).map do |nested_model|
              nested_model.valid?(*args, **kwargs, &block)
            end
          end.all?
          self_valid && nested_valid
        end
      end

      def allow_reflection_on(models)
        # Allow reflection on all the nested attributes within a class. This defines
        # a method on the form class itself that reduces copypasta in other places, e.g.,
        # param validation in controllers.
        # Since accepts_nested_attributes may be called multiple times, this merges the
        # nested attributes previously defined.
        new_nested_attributes = models.to_h { |model| [:"#{model}_attributes", {}] }
        new_nested_model_names = models
        if defined? nested_attributes
          new_nested_attributes.merge!(nested_attributes)
          new_nested_model_names.concat(nested_model_names)
        end
        singleton_class.define_method(:nested_attributes) do
          new_nested_attributes
        end
        singleton_class.define_method(:nested_model_names) do
          new_nested_model_names
        end
      end
    end
  end
end
