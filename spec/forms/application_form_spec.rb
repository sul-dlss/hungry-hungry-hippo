# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationForm do
  describe '.model_name' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns a model name without the Form suffix' do
      expect(TestForm.model_name.to_s).to eq('Test')
    end
  end

  describe '.immutable_attributes' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns an empty array by default' do
      expect(TestForm.immutable_attributes).to eq([])
    end
  end

  describe '.permitted_params' do
    let(:test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        attribute :bar, array: true
        attribute :baz, :string

        has_many :widgets
        has_one :publication_date

        def self.immutable_attributes
          [:baz]
        end
      end
    end

    let(:widget_form_class) { Class.new(described_class) }
    let(:publication_date_form_class) { Class.new(described_class) }

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('PublicationDateForm', publication_date_form_class)
      stub_const('TestForm', test_form_class)
    end

    it 'includes editable attributes and nested attributes keys' do
      expect(TestForm.permitted_params).to include(:foo, { bar: [] },
                                                   widgets_attributes: {}, publication_date_attributes: {})
      expect(TestForm.permitted_params).not_to include(:baz)
    end
  end

  describe '.has_many and .has_one' do
    subject(:form_instance) { TestForm.new }

    let(:test_form_class) do
      Class.new(described_class) do
        has_many :widgets, prepopulate_if_empty: true, prepopulate_count: 2
        has_one :publication_date, prepopulate_if_empty: true
      end
    end

    let(:widget_form_class) do
      Class.new(described_class) do
        attribute :fake_attr, :string
      end
    end

    let(:publication_date_form_class) do
      Class.new(described_class) do
        attribute :year, :integer
      end
    end

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('PublicationDateForm', publication_date_form_class)
      stub_const('TestForm', test_form_class)
    end

    it 'stores has_many metadata in associations' do
      expect(TestForm.associations['widgets']).to include(type: :has_many, class_name: 'WidgetForm', primary_key: 'id')
      expect(form_instance.widgets).to be_empty
    end

    it 'stores options for has_many in nested_attributes_options' do
      expect(TestForm.nested_attributes_options['widgets']).to include(prepopulate_if_empty: true, prepopulate_count: 2)
    end

    it 'stores has_one metadata in associations' do
      expect(TestForm.associations['publication_date']).to include(type: :has_one,
                                                                   class_name: 'PublicationDateForm',
                                                                   primary_key: 'id')
      expect(form_instance.publication_date).to be_nil
    end

    it 'stores options for has_one in nested_attributes_options' do
      expect(TestForm.nested_attributes_options['publication_date']).to include(prepopulate_if_empty: true)
    end

    it 'hydrates has_one attributes as a single nested form' do
      form_instance.publication_date_attributes = { year: 2024 }

      expect(form_instance.publication_date).to be_a(PublicationDateForm)
      expect(form_instance.publication_date.year).to eq(2024)
    end

    it 'prepopulate! builds minimum rows for has_many' do
      form_instance.prepopulate!

      expect(form_instance.widgets.size).to eq(2)
      expect(form_instance.widgets.to_a).to all(be_a(WidgetForm))
    end

    it 'prepopulate! builds empty has_one when configured' do
      form_instance.prepopulate!

      expect(form_instance.publication_date).to be_a(PublicationDateForm)
    end

    it 'prepopulate! returns self' do
      expect(form_instance.prepopulate!).to eq(form_instance)
    end
  end

  describe '.nested_attributes_options' do
    let(:test_form_class) do
      Class.new(described_class) do
        has_many :widgets, allow_destroy: true
        has_one :publication_date, reject_if: :all_blank
      end
    end

    let(:widget_form_class) { Class.new(described_class) }
    let(:publication_date_form_class) { Class.new(described_class) }

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('PublicationDateForm', publication_date_form_class)
      stub_const('TestForm', test_form_class)
    end

    it 'stores options keyed by association name strings' do
      expect(TestForm.nested_attributes_options).to include(
        'widgets' => include(allow_destroy: true),
        'publication_date' => include(reject_if: :all_blank)
      )
    end
  end

  describe '.nested attributes inheritance' do
    subject(:child_form_instance) { ChildTestForm.new }

    let(:base_test_form_class) do
      Class.new(described_class) do
        has_many :widgets, prepopulate_if_empty: true
        has_many :gadgets, prepopulate_if_empty: true
      end
    end

    let(:child_test_form_class) do
      Class.new(base_test_form_class) do
        has_many :thingamabobs, prepopulate_if_empty: true
      end
    end

    let(:widget_form_class) { Class.new(described_class) }
    let(:gadget_form_class) { Class.new(described_class) }
    let(:thingamabob_form_class) { Class.new(described_class) }

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('GadgetForm', gadget_form_class)
      stub_const('ThingamabobForm', thingamabob_form_class)
      stub_const('TestForm', base_test_form_class)
      stub_const('ChildTestForm', child_test_form_class)
    end

    it 'exposes nested attributes from parent and child' do
      expect(ChildTestForm.nested_attributes).to eq(
        widgets_attributes: {},
        gadgets_attributes: {},
        thingamabobs_attributes: {}
      )
    end

    it 'merges nested attribute options from parent and child' do
      expect(ChildTestForm.nested_attributes_options).to include('widgets', 'gadgets', 'thingamabobs')
    end

    it 'supports prepopulation across inherited nested associations' do
      child_form_instance.prepopulate!

      expect(child_form_instance.widgets).to be_present
      expect(child_form_instance.gadgets).to be_present
      expect(child_form_instance.thingamabobs).to be_present
    end
  end

  describe '#loggable_errors' do
    subject(:form) { TestForm.new(widgets_attributes: [{}]) }

    let(:test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        validates :foo, presence: true, on: :deposit
        has_many :widgets
      end
    end

    let(:widget_form_class) do
      Class.new(described_class) do
        attribute :fake_attr, :string
        validates :fake_attr, presence: true, on: :deposit
      end
    end

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('TestForm', test_form_class)
    end

    it 'returns an empty array when there are no errors' do
      expect(form).to be_valid
      expect(form.loggable_errors).to eq([])
    end

    it 'returns loggable errors for top-level and nested validation failures' do
      expect(form.valid?(:deposit)).to be(false)
      expect(form.loggable_errors).to include('Test foo: blank', 'Test widgets: invalid')
    end
  end
end
