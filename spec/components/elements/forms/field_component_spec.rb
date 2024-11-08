# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::FieldComponent do
  let(:field) { described_class.new(form: nil, field_name: nil) }

  it 'creates field with default label' do
    expect(field.label_class).to eq('form-label')
    expect(field.label_classes).to eq('form-label')
    expect(field.label_text).to be_nil
  end

  context 'with custom field label text' do
    let(:field) { described_class.new(form: nil, field_name: nil, label: 'My field label') }

    it 'creates field with the label' do
      expect(field.label_class).to eq('form-label')
      expect(field.label_classes).to eq('form-label')
      expect(field.label_text).to eq('My field label')
    end
  end

  context 'with a hidden label' do
    let(:field) { described_class.new(form: nil, field_name: nil, hidden_label: true) }

    it 'creates field with hidden label' do
      expect(field.label_class).to eq('form-label')
      expect(field.label_classes).to eq('form-label visually-hidden')
    end
  end
end
