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
        define_getters_for_nested_models(models)
        define_setters_for_nested_models(models)
        allow_reflection_on_nested_models(models)
        allow_serialization_of_nested_models(models)
      end

      private

      def define_getters_for_nested_models(models)
        # For each nested attribute, define a getter
        models.each do |model|
          # Each nested attribute needs a getter for ActiveModel::Serialization to include it in its related model.
          define_method(:"#{model}") do
            # Default the instance variable to an empty array so we can append to it below.
            instance_variable_get(:"@#{model}") || []
          end
        end
      end

      def define_setters_for_nested_models(models)
        # For each nested attribute, define a setter
        models.each do |model|
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
                model.to_s.classify.concat('Form').constantize.new(attributes)
              )
            end
          end
        end
      end

      def allow_reflection_on_nested_models(models)
        # Allow reflection on all the nested attributes within a class. This defines
        # a method on the form class itself that reduces copypasta in other places, e.g.,
        # param validation in controllers.
        singleton_class.define_method(:nested_attributes_hash) do
          models.index_with { {} }
        end
      end

      def allow_serialization_of_nested_models(models)
        # Allows serialization of the form using ActiveModel::Serialization
        define_method(:attributes) do
          # Keys *must* be strings
          super().merge(models.to_h { |attr| [attr.to_s, public_send(attr).map(&:attributes)] })
        end
      end
    end
  end
end
