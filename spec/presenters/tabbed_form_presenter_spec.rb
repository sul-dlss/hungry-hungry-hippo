# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TabbedFormPresenter do
  let(:model) { WorkForm.new }

  describe '#form_id' do
    it 'computes a dom_id from the model' do
      presenter = described_class.new(model:, default_tab_name: :files)

      expect(presenter.form_id).to eq(ActionView::RecordIdentifier.dom_id(model, 'tabbed_form'))
    end
  end

  describe '#discard_draft_form_id' do
    it 'returns exactly what was passed in' do
      presenter = described_class.new(model:, default_tab_name: :files, discard_draft_form_id: 'some_id')

      expect(presenter.discard_draft_form_id).to eq('some_id')
    end

    it 'returns nil when nil is passed in' do
      presenter = described_class.new(model:, default_tab_name: :files, discard_draft_form_id: nil)

      expect(presenter.discard_draft_form_id).to be_nil
    end

    it 'defaults to nil when not given' do
      presenter = described_class.new(model:, default_tab_name: :files)

      expect(presenter.discard_draft_form_id).to be_nil
    end
  end

  describe '#active_tab_name' do
    it 'prefers the requested tab over the default' do
      presenter = described_class.new(model:, default_tab_name: :files, active_tab_name: :title)

      expect(presenter.active_tab_name).to eq(:title)
    end

    it 'falls back to the default tab when no tab was requested' do
      presenter = described_class.new(model:, default_tab_name: :files, active_tab_name: nil)

      expect(presenter.active_tab_name).to eq(:files)
    end
  end
end
