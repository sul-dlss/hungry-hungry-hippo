# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationForm do
  describe '.model_name' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns a model name without the "Form" suffix' do
      expect(TestForm.model_name).to eq('Test')
    end
  end

  describe '.immutable_attributes' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns an empty array' do
      expect(TestForm.immutable_attributes).to be_empty
    end
  end

  describe '.user_editable_attributes' do
    let(:test_form_class) do
      Class.new(described_class) do
        def self.attribute_names
          %i[foo bar baz]
        end

        def self.immutable_attributes
          [:baz]
        end
      end
    end

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns attributes not declared as immutable' do
      expect(TestForm.user_editable_attributes).to eq(%i[foo bar])
    end
  end

  describe '.accepts_nested_attributes_for' do
    subject(:form_instance) { TestForm.new }

    let(:test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        accepts_nested_attributes_for :widgets, :gadgets
      end
    end

    let(:widget_form_class) do
      Class.new(described_class) do
        attribute :fake_attr, :string
      end
    end

    let(:gadget_form_class) do
      Class.new(described_class) do
        attribute :fake_attr, :string
      end
    end

    before do
      stub_const('TestForm', test_form_class)
      stub_const('WidgetForm', widget_form_class)
      stub_const('GadgetForm', gadget_form_class)
    end

    %i[widgets gadgets].each do |model|
      it 'defines an instance getter that defaults to an empty array' do
        expect(form_instance.public_send(model)).to eq([])
      end

      it 'defines an instance setter that can take a hash argument' do
        form_instance.public_send(:"#{model}=", { 'fake_id_here' => { 'fake_attr' => 'real_value' } })
        expect(form_instance.public_send(model)).to contain_exactly(
          instance_of(model.to_s.classify.concat(described_class::FORM_CLASS_SUFFIX).constantize)
        )
      end

      it 'defines an instance setter that can take an array argument' do
        form_instance.public_send(:"#{model}=", [{ 'fake_attr' => 'real_value' }])
        expect(form_instance.public_send(model)).to contain_exactly(
          instance_of(model.to_s.classify.concat(described_class::FORM_CLASS_SUFFIX).constantize)
        )
      end
    end

    it 'overrides the instance-level attributes method to include nested attributes' do
      expect(form_instance.attributes.keys).to contain_exactly('foo', 'widgets', 'gadgets')
    end

    it 'defines a class-level nested_attributes_hash method that returns nested attribute names' do
      expect(TestForm.nested_attributes_hash).to eq({ widgets: {}, gadgets: {} })
    end
  end
end
