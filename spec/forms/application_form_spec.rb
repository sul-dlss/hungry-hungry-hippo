# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationForm do
  describe '.model_name' do
    before do
      test_form_class = Class.new(described_class)
      stub_const('TestForm', test_form_class)
    end

    it 'returns a model name without the "Form" suffix' do
      expect(TestForm.model_name).to eq('Test')
    end
  end
end
