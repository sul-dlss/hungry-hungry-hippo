# frozen_string_literal: true

module ActiveModel
  module Validations
    # Borrowed from ActiveRecord: https://github.com/rails/rails/blob/90a1eaa1b30ba1f2d524e197460e549c03cf5698/activerecord/lib/active_record/validations/associated.rb
    class AssociatedValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return if Array(value).reject { |association| association.valid?(record.validation_context.presence) }.none?

        record.errors.add(attribute, :invalid, **options, value:)
      end
    end
  end
end
