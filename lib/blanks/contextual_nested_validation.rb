# frozen_string_literal: true

module Blanks
  # Ensures nested form validation uses the current validation context.
  module ContextualNestedValidation
    def valid?(context = nil)
      @nested_validation_context = context

      run_callbacks :validation do
        parent_valid = ActiveModel::Validations.instance_method(:valid?).bind_call(self, context)
        nested_valid = nested_forms_valid?
        parent_valid && nested_valid
      end
    ensure
      @nested_validation_context = nil
    end

    private

    def nested_forms_valid? # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      context = @nested_validation_context.presence
      all_valid = true

      self.class.associations.each do |name, association|
        nested_form = public_send(name)
        next if nested_form.nil?

        case association[:type]
        when :has_one
          unless nested_form.valid?(context)
            errors.add(name.to_sym, :invalid, value: nested_form)
            copy_nested_errors(name, nested_form)
            all_valid = false
          end
        when :has_many
          added_association_error = false
          nested_form.each_with_index do |form, index|
            next if form.valid?(context)

            unless added_association_error
              errors.add(name.to_sym, :invalid, value: nested_form)
              added_association_error = true
            end
            copy_nested_errors("#{name}[#{index}]", form)
            all_valid = false
          end
        end
      end

      all_valid
    end
  end
end
