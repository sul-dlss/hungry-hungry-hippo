# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AffiliationForm, type: :form do
  let(:form) { described_class.new(institution:, uri:, department:) }

  let(:institution) { nil }
  let(:uri) { nil }
  let(:department) { nil }

  describe 'validations' do
    context 'when institution, uri, and department are all present' do
      let(:institution) { 'Stanford University' }
      let(:uri) { 'https://ror.org/00f54p054' }
      let(:department) { 'Department of Computer Science' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when institution but not uri is present' do
      let(:institution) { 'Stanford University' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:institution]).to include('must be selected from the list')
      end
    end

    context 'when institution and uri are both present' do
      let(:institution) { 'Stanford University' }
      let(:uri) { 'https://ror.org/00f54p054' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when department but not institution is present' do
      let(:department) { 'Department of Computer Science' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:institution]).to include("can't be blank")
      end
    end
  end
end
