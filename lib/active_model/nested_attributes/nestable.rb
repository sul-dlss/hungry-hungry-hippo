# frozen_string_literal: true

module ActiveModel
  module NestedAttributes
    # Internal mixin for nested attribute acceptance behavior.
    #
    # This module encapsulates ActiveModel-specific behavior similar in spirit to
    # ActiveRecord nested attributes assignment: class-level declaration,
    # generated writers, nested validation wiring, and normalized serialization.
    #
    # @see ActiveRecord::NestedAttributes::ClassMethods
    #
    # @!method nested_attributes
    #   Returns nested attribute keys suitable for strong parameters.
    #   @return [Hash{Symbol => Hash}] e.g. `{ contributors_attributes: {}, publication_date_attributes: {} }`
    #
    # @!method serializable_hash(**serialize_options)
    #   Serializes the form and rewrites nested keys to Rails-style `*_attributes` keys.
    #   @param serialize_options [Hash] options passed through to ActiveModel serialization
    #   @return [Hash] serialized form payload including nested attributes
    module Nestable
      # Configures nested attribute hydration, validation, and serialization for
      # one or more associations.
      #
      # For each provided association, this method:
      # 1. Resolves the nested form class name (`<Association>Form`)
      # 2. Defines the base ActiveModel attribute and `*_attributes=` writer
      # 3. Registers nested metadata for reflection
      # 4. Installs associated validation and serializable hash key normalization
      #
      # @param attr_names [Array<Symbol,String>] nested association names
      # @param options [Hash] options applied to each association
      # @option options [Symbol] :cardinality required; either `:many` or `:one`
      # @option options [Integer] :minimum_rows minimum rows to seed during render prep
      # @option options [Boolean] :render_if_empty whether to seed blank nested forms
      # @raise [KeyError] when `:cardinality` is not provided
      # @raise [NameError] when a nested form class cannot be resolved
      #   (for example, `contributors` without `ContributorForm`)
      # @return [void]
      #
      # @api private
      # @see ActiveModel::NestedAttributes::Seedable#seed_for_form_render!
      # @see ActiveModel::Validations::AssociatedValidator
      def accepts_nested_attributes_for(*attr_names, **options) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        associations = attr_names.to_h do |association|
          nested_klass = "#{association.to_s.classify}Form".safe_constantize

          raise NameError, "Unable to find class #{association.to_s.classify}Form" if nested_klass.blank?

          [
            association,
            {
              klass: nested_klass,
              options: options.except(:cardinality),
              repeatable: options.fetch(:cardinality) == :many
            }
          ]
        end

        self.nested_association_definitions = nested_association_definitions.merge(associations)
        self.nested_attributes_options = nested_attributes_options.merge(
          associations.transform_values { |config| config[:options] }
        )

        associations.each do |association, config|
          # Set up each nested attribute as a legitimate ActiveModel attribute
          attribute association, default: -> { config[:repeatable] ? [] : nil }

          # @example Repeatable writer accepts array and hash-like payloads
          #   form.contributors_attributes = {
          #     "0" => { first_name: "Ada", last_name: "Lovelace" },
          #     "1" => { first_name: "Grace", last_name: "Hopper" }
          #   }
          define_method(:"#{association}_attributes=") do |params|
            if config[:repeatable]
              hydrated_models = normalize_nested_collection_params(params).map do |nested_attrs|
                config[:klass].new(nested_attrs)
              end
              public_send(:"#{association}=", hydrated_models)
            else
              nested_model = public_send(association).presence || config[:klass].new
              nested_model.assign_attributes(params) if params
              public_send(:"#{association}=", nested_model)
            end
          end
        end

        # Ensure all nested models are valid, inspired by `validates_associated` from ActiveRecord
        validates_with ActiveModel::Validations::AssociatedValidator,
                       _merge_attributes(nested_association_definitions.keys)

        # Allow reflection on all the nested attributes within a class. This defines
        # a method on the form class itself that reduces copypasta in other places, e.g.,
        # param validation in controllers.
        singleton_class.define_method(:nested_attributes) do
          nested_association_definitions.keys.to_h { |association| [:"#{association}_attributes", {}] }
        end

        # Transform nested forms into Rails-standard attribute hashes (e.g.,
        # those that come in from form submissions)
        define_method(:serializable_hash) do |**serialize_options|
          super(**serialize_options)
            .deep_transform_keys do |association|
            # When going from form to hash (serializing), represent nested
            # attributes by making sure their keys end in '_attributes' per
            # standard ActiveRecord practice
            self.class.nested_attributes.key?(:"#{association}_attributes") ? "#{association}_attributes" : association
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
