# frozen_string_literal: true

module ActiveModel
  # Adds ActiveRecord-like nested attributes behavior to ActiveModel form objects.
  #
  # This concern provides a small DSL (`has_one`, `has_many`) for declaring
  # nested form associations, hydration writers (`*_attributes=`), validation of
  # nested children, and form-render seeding helpers via
  # {ActiveModel::NestedAttributes::Seedable#seed_for_form_render!}.
  #
  # Unlike ActiveRecord, this module does not persist associations. It focuses on
  # in-memory form object composition and serialization.
  #
  # @example Declaring nested forms in a form object
  #   class ApplicationForm
  #     include ActiveModel::NestedAttributes
  #   end
  #
  #   class WorkForm < ApplicationForm
  #     has_many :contributors, minimum_rows: 1
  #     has_one :publication_date, render_if_empty: true
  #   end
  #
  # @see ActiveRecord::NestedAttributes::ClassMethods
  # @see ActiveModel::NestedAttributes::Nestable
  # @see ActiveModel::NestedAttributes::Normalizable
  # @see ActiveModel::NestedAttributes::Seedable
  #
  # @!attribute [rw] nested_association_definitions
  #   Declared nested association metadata.
  #   @return [Hash{Symbol => Hash}] association definition config keyed by association name
  #
  # @!attribute [rw] nested_attributes_options
  #   Render/hydration options for nested associations.
  #   @return [Hash{Symbol => Hash}] options keyed by association name
  module NestedAttributes
    extend ActiveSupport::Concern

    include ActiveModel::Model # Include this one first!
    include ActiveModel::Attributes
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks
    include Normalizable
    include Seedable

    included do
      class_attribute :nested_association_definitions, default: {}
      class_attribute :nested_attributes_options, default: {}
    end

    class_methods do
      include Nestable

      # Declares a repeatable nested form association.
      #
      # Internally, this delegates to `accepts_nested_attributes_for` with
      # `cardinality: :many`.
      #
      # @param attr_names [Array<Symbol,String>] nested association names
      # @param options [Hash] nested association options
      # @option options [Integer] :minimum_rows minimum rows to seed for form rendering
      # @option options [Boolean] :render_if_empty whether at least one row should be seeded
      # @return [void]
      #
      # @example
      #   has_many :contributors, minimum_rows: 2
      #
      # @api public
      # @see #accepts_nested_attributes_for
      def has_many(*attr_names, **)
        accepts_nested_attributes_for(*attr_names, **, cardinality: :many)
      end

      # Declares a singular nested form association.
      #
      # Internally, this delegates to `accepts_nested_attributes_for` with
      # `cardinality: :one`.
      #
      # @param attr_names [Array<Symbol,String>] nested association names
      # @param options [Hash] nested association options
      # @option options [Boolean] :render_if_empty whether a blank child should be seeded
      # @return [void]
      #
      # @example
      #   has_one :publication_date, render_if_empty: true
      #
      # @api public
      # @see #accepts_nested_attributes_for
      def has_one(*attr_names, **)
        accepts_nested_attributes_for(*attr_names, **, cardinality: :one)
      end
    end
  end
end
