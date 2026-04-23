# frozen_string_literal: true

module ActiveModel
  module Validations
    # Validates that associated nested form objects are valid.
    #
    # Behavior is intentionally inspired by ActiveRecord's associated validator
    # and adapted for ActiveModel-based form objects.
    #
    # @example
    #   validates_with ActiveModel::Validations::AssociatedValidator,
    #     _merge_attributes([:contributors, :publication_date])
    #
    # @see ActiveRecord::Validations::AssociatedValidator
    # @see ActiveModel::NestedAttributes::Nestable
    class AssociatedValidator < ActiveModel::EachValidator
      # Validates a single association attribute on the record.
      #
      # @param record [ActiveModel::Validations] model/form record being validated
      # @param attribute [Symbol] attribute name containing association(s)
      # @param value [Object, Array<Object>, nil] association object(s) to validate
      # @return [void]
      # @see ActiveModel::Errors#add
      def validate_each(record, attribute, value)
        return if Array(value).reject { |association| association.valid?(record.validation_context.presence) }.none?

        record.errors.add(attribute, :invalid, **options, value:)
      end
    end
  end
end
