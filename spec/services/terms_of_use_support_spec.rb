# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfUseSupport do
  describe '.full_statement' do
    subject(:full_statement) { described_class.full_statement(custom_rights_statement:) }

    context 'when custom rights statement is provided' do
      let(:custom_rights_statement) { 'My custom rights statement. ' }

      it 'returns the full statement' do
        expect(full_statement).to match(/^My custom rights statement.\r\n\r\nUser agrees that, where applicable,/)
      end
    end

    context 'when custom rights statement is empty' do
      let(:custom_rights_statement) { '' }

      it 'returns only the default terms of use' do
        expect(full_statement).to eq(described_class.default_terms_of_use)
      end
    end
  end

  describe '.custom_rights_statement' do
    subject(:custom_rights_statement) { described_class.custom_rights_statement(use_statement:) }

    context 'when there is a custom rights statement' do
      let(:use_statement) { "My custom rights statement\r\n\r\n#{described_class.default_terms_of_use}" }

      it 'returns the custom rights statement without the default terms of use' do
        expect(custom_rights_statement).to eq('My custom rights statement')
      end
    end

    context 'when use statement is blank' do
      let(:use_statement) { '' }

      it 'returns nil' do
        expect(custom_rights_statement).to be_nil
      end
    end

    context 'when use statement is the default terms of use' do
      let(:use_statement) { described_class.default_terms_of_use }

      it 'returns nil' do
        expect(custom_rights_statement).to be_nil
      end
    end
  end

  describe '.default_terms_of_use' do
    it 'returns the default terms of use from I18n' do
      expect(described_class.default_terms_of_use).to match(/^User agrees that, where applicable,/)
    end
  end
end
