# frozen_string_literal: true

require 'active_support/concern'

module ActiveModel
  # Mimic ActiveRecord::NestedAttributes for ActiveModel objects
  module NestedAttributes
    extend ActiveSupport::Concern

    include ActiveModel::Model # Include this one first!
    include ActiveModel::Attributes
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks

    class_methods do
      # Allows a form to accept and handle attributes for models nested within it.
      def accepts_nested_attributes_for(*models) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        models.each do |model|
          repeatable = model.to_s.pluralize == model.to_s
          nested_klass = model.to_s.classify.concat('Form').constantize

          # Set up each nested attribute as a legitimate ActiveModel attribute
          attribute model, default: -> { repeatable ? [] : nil }

          # Add a builder for each nested attribute, primarily used for
          # replacing blank values with stubbed out ones for rendering forms
          define_method(:"build_#{model}") do
            return if public_send(model).present?

            public_send(:"#{model}_attributes=", repeatable ? [{}] : {})
          end

          # Takes literals (strings, arrays, hashes) as input and "hydrates" them into the proper form classes
          define_method(:"#{model}_attributes=") do |params|
            if repeatable
              # Either hashes or arrays may be passed to this method, so account
              # for both. Note that the keys in the hashes may be ignored, as
              # they are integers reflecting the order of the values.
              Array(params.respond_to?(:values) ? params.values : params).each do |nested_attrs|
                public_send(model).push(nested_klass.new(nested_attrs))
              end
            else
              nested_model = public_send(model).presence || nested_klass.new
              nested_model.assign_attributes(params) if params
              public_send(:"#{model}=", nested_model)
            end
          end
        end

        # Replace empty nested values with new ones
        define_method(:prepopulate) do
          models.each do |model|
            public_send(:"build_#{model}")

            # This allows prepopulation of nested models within nested models
            nested_model = public_send(model)
            if nested_model.respond_to?(:to_ary) && nested_model.first.respond_to?(:prepopulate)
              nested_model.map(&:prepopulate)
            elsif nested_model.respond_to?(:prepopulate)
              nested_model.prepopulate
            end
          end

          self
        end

        # Ensure all nested models are valid, inspired by `validate_associated` from ActiveRecord
        validates_with ActiveModel::Validations::AssociatedValidator, _merge_attributes(models)

        # Allow reflection on all the nested attributes within a class. This defines
        # a method on the form class itself that reduces copypasta in other places, e.g.,
        # param validation in controllers.
        singleton_class.define_method(:nested_attributes) do
          models.to_h { |model| [:"#{model}_attributes", {}] }
        end

        # Transform nested forms into Rails-standard attribute hashes (e.g.,
        # those that come in from form submissions)
        define_method(:serializable_hash) do |**options|
          super(**options)
            .deep_transform_keys do |attr_name|
              # When going from form to hash (serializing), represent nested
              # attributes by making sure their keys end in '_attributes' per
              # standard ActiveRecord practice
              singleton_class.nested_attributes.key?(:"#{attr_name}_attributes") ? "#{attr_name}_attributes" : attr_name
          end # rubocop:disable Style/MultilineBlockChain
            .deep_transform_values do |value|
              # Leverage ActiveModel serialization to make sure nested models are serialized recursively
              value.respond_to?(:serializable_hash) ? value.serializable_hash : value
          end
        end
      end
    end
  end
end
