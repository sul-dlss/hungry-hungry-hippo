# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::FieldComponent do
  let(:field) { described_class.new(form: nil, field_name: nil) }

  it 'creates field with label' do
    expect(field.label_class).to eq('form-label')
    expect(field.label_classes).to eq('form-label')
  end

  it 'creates field with hidden label' do
    field = described_class.new(form: nil, field_name: nil, hidden_label: true)

    expect(field.label_class).to eq('form-label')
    expect(field.label_classes).to eq('form-label visually-hidden')
  end
end
