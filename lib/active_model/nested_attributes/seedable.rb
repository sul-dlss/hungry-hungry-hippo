# frozen_string_literal: true

module ActiveModel
  module NestedAttributes
    # Provides rendering-time nested form seeding helpers.
    #
    # These methods prepare nested form objects so view rendering can reliably
    # iterate over expected structures (for example, always at least one row in a
    # repeatable section).
    #
    # @see ActiveRecord::NestedAttributes::ClassMethods
    # @see ActionView::Helpers::FormHelper#fields_for
    module Seedable
      # Seeds nested associations for form rendering.
      #
      # All declared nested associations are prepared.
      #
      # @return [self]
      #
      # @example Seed all declared associations
      #   form.seed_for_form_render!
      #
      # @see #ensure_nested_for_render!
      # @see #normalize_nested_collection_params
      # @see ActionView::Helpers::FormBuilder#fields_for
      # @api public
      def seed_for_form_render!
        declared_associations_for_render.each do |association_name|
          ensure_nested_for_render!(association_name)
        end

        recursively_prepare_nested_associations(declared_associations_for_render)

        self
      end

      private

      # Returns all declared associations for render-time seeding.
      #
      # @return [Array<Symbol>] associations to seed in advance of rendering
      # @api private
      def declared_associations_for_render
        @declared_associations_for_render ||= self.class.nested_association_definitions.keys
      end

      # Recursively seeds children for already-prepared associations.
      #
      # @param associations [Array<Symbol,String>] association names to recurse into
      # @return [void]
      # @api private
      def recursively_prepare_nested_associations(associations)
        associations.each do |association_name|
          nested_model = public_send(association_name)

          Array(nested_model).each do |child|
            child.seed_for_form_render! if child.respond_to?(:seed_for_form_render!)
          end
        end
      end

      # Ensures a single association has required render-time shape.
      #
      # @param association_name [Symbol,String] nested association to prepare
      # @param minimum_rows [Integer,nil] explicit minimum rows override for repeatable associations
      # @return [void]
      #
      # @raise [KeyError] when the association is not declared
      # @api private
      def ensure_nested_for_render!(association_name, minimum_rows: nil)
        config = self.class.nested_association_definitions.fetch(association_name.to_sym)
        if config[:repeatable]
          ensure_repeatable_nested_for_render!(association_name:, config:, minimum_rows:)
        else
          ensure_single_nested_for_render!(association_name:, config:)
        end
      end

      # Ensures repeatable nested associations have at least the required number
      # of rows.
      #
      # @param association_name [Symbol,String] repeatable association attribute
      # @param config [Hash] association metadata entry
      # @param minimum_rows [Integer,nil] explicit minimum rows override
      # @return [void]
      # @api private
      def ensure_repeatable_nested_for_render!(association_name:, config:, minimum_rows:)
        required_rows = minimum_rows || required_nested_rows(config:)
        current = Array(public_send(association_name))
        number_of_rows_to_add = [0, required_rows - current.size].max
        current.concat(Array.new(number_of_rows_to_add) { config[:klass].new })
      end

      # Ensures singular nested associations are present when required.
      #
      # @param association_name [Symbol,String] singular association attribute
      # @param config [Hash] association metadata entry
      # @return [void]
      # @api private
      def ensure_single_nested_for_render!(association_name:, config:)
        return if public_send(association_name).present?

        public_send(:"#{association_name}=", config[:klass].new)
      end

      # Computes minimum rows for repeatable nested associations.
      #
      # @param config [Hash] association metadata entry
      # @return [Integer] required row count
      # @api private
      def required_nested_rows(config:)
        minimum_rows = config[:options][:minimum_rows].to_i
        return minimum_rows if minimum_rows.positive?

        1
      end
    end
  end
end
