# frozen_string_literal: true

# Presents a nested component based on the arity of the form field
class NestedComponentPresenter
  def self.for(...)
    new(...).for
  end

  def initialize(form:, field_name:, **kwargs)
    @form = form
    @field_name = field_name
    @kwargs = kwargs
  end

  attr_reader :form, :field_name, :kwargs

  def for
    nested_class.new(form:, field_name:, **kwargs)
  end

  private

  def nested_class
    return Elements::Forms::RepeatableNestedComponent if one_to_many?

    Elements::Forms::NonRepeatableNestedComponent
  end

  def one_to_many?
    form.object.public_send(field_name).respond_to?(:to_ary)
  end
end
