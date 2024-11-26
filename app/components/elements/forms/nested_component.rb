# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a nested form, including adding and removing nested models.
    class NestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component: all_strings_form_component)
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component

      def add_button_label
        "+ Add another #{model_class.model_name.singular.humanize(capitalize: false)}"
      end

      def header_label
        model_class.model_name.plural.humanize
      end

      private

      def all_strings_form_component
        Class.new(ApplicationComponent) do
          def self.name
            'NaiveFormComponent'
          end

          attr_reader :form

          def initialize(form:)
            @form = form

            if @form.object.class.attribute_types.any? { |_, field_type_instance| field_type_instance.type != :string }
              raise ArgumentError, "#{@form.object} has one or more non-string field types, so the `form_component:` " \
                                   'keyword argument must be passed to NestedComponent.'
            end

            super()
          end

          def call
            safe_join(
              form.object.attribute_names.map do |field_name|
                render(
                  Elements::Forms::TextFieldComponent.new(
                    field_name:,
                    form:,
                    label: I18n.t("#{form.object.model_name.plural}.edit.fields.#{field_name}.label")
                  )
                )
              end
            )
          end
        end
      end
    end
  end
end
