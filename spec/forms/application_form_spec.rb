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
        attribute :foo, :string
        attribute :bar, array: true
        attribute :baz, :string

        def self.immutable_attributes
          [:baz]
        end
      end
    end

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns attributes not declared as immutable' do
      expect(TestForm.send(:user_editable_attributes)).to eq([:foo, { bar: [] }])
    end
  end

  describe '.has_many and .has_one' do
    subject(:form_instance) { TestForm.new }

    let(:test_form_class) do
      Class.new(described_class) do
        has_many :widgets, render_if_empty: true, minimum_rows: 2
        has_one :publication_date, render_if_empty: true
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

    it 'sets explicit cardinality metadata for has_many' do
      expect(TestForm.nested_association_definitions[:widgets][:repeatable]).to be(true)
      expect(form_instance.widgets).to eq([])
    end

    it 'supports render options metadata for has_many' do
      expect(TestForm.nested_attributes_options[:widgets]).to include(render_if_empty: true, minimum_rows: 2)
    end

    it 'sets explicit cardinality metadata for has_one' do
      expect(TestForm.nested_association_definitions[:publication_date][:repeatable]).to be(false)
      expect(form_instance.publication_date).to be_nil
    end

    it 'supports render options metadata for has_one' do
      expect(TestForm.nested_attributes_options[:publication_date]).to include(render_if_empty: true)
    end

    it 'hydrates has_one attributes as a single form object' do
      form_instance.publication_date_attributes = { year: 2024 }

      expect(form_instance.publication_date).to be_a(PublicationDateForm)
      expect(form_instance.publication_date.year).to eq(2024)
    end

    it 'seed_for_form_render! builds minimum rows for has_many' do
      form_instance.seed_for_form_render!

      expect(form_instance.widgets.size).to eq(2)
      expect(form_instance.widgets).to all(be_a(WidgetForm))
    end

    it 'seed_for_form_render! builds empty has_one when configured' do
      form_instance.seed_for_form_render!

      expect(form_instance.publication_date).to be_a(PublicationDateForm)
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

    it 'stores options keyed by nested association name' do
      expect(TestForm.nested_attributes_options).to eq(
        widgets: { allow_destroy: true },
        publication_date: { reject_if: :all_blank }
      )
    end
  end

  describe '.seed_for_form_render!' do
    subject(:form_instance) { TestForm.new }

    let(:test_form_class) do
      Class.new(described_class) do
        has_many :widgets, minimum_rows: 1
        has_one :publication_date, render_if_empty: true
      end
    end

    let(:widget_form_class) { Class.new(described_class) }
    let(:publication_date_form_class) { Class.new(described_class) }

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('PublicationDateForm', publication_date_form_class)
      stub_const('TestForm', test_form_class)
    end

    it 'seed_for_form_render! returns self' do
      expect(form_instance.seed_for_form_render!).to eq(form_instance)
    end
  end

  describe '.nested_attributes inheritance' do
    subject(:child_form_instance) { ChildTestForm.new }

    let(:base_test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        has_many :widgets, :gadgets
      end
    end

    let(:child_test_form_class) do
      Class.new(base_test_form_class) do
        has_many :thingamabobs
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

    let(:thingamabob_form_class) do
      Class.new(described_class) do
        attribute :fake_attr, :string
      end
    end

    before do
      stub_const('WidgetForm', widget_form_class)
      stub_const('GadgetForm', gadget_form_class)
      stub_const('ThingamabobForm', thingamabob_form_class)
      stub_const('TestForm', base_test_form_class)
      stub_const('ChildTestForm', child_test_form_class)
    end

    it 'merges nested attribute definitions from parent and child' do
      expect(ChildTestForm.nested_attributes).to eq({ widgets_attributes: {}, gadgets_attributes: {},
                                                      thingamabobs_attributes: {} })
    end

    it 'merges nested attributes options from parent and child' do
      expect(ChildTestForm.nested_attributes_options).to eq({ widgets: {}, gadgets: {}, thingamabobs: {} })
    end

    it 'supports render preparation across inherited nested associations' do
      child_form_instance.seed_for_form_render!

      expect(child_form_instance.widgets).to be_present
      expect(child_form_instance.gadgets).to be_present
      expect(child_form_instance.thingamabobs).to be_present
    end
  end

  describe '.loggable_errors' do
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
      expect(form.loggable_errors).to be_empty
    end

    it 'returns loggable errors when there are errors' do
      expect(form.valid?(:deposit)).to be false
      expect(form.loggable_errors).to eq ['Test foo: blank', 'Test widgets: invalid']
    end
  end
end
