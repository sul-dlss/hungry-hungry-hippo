# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  describe 'work type validations' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        authors_attributes: authors_fixture,
        work_type:, work_subtypes:, other_work_subtype:
      )
    end
    let(:work_type) { '' }
    let(:work_subtypes) { [] }
    let(:other_work_subtype) { '' }

    context 'when saving draft with blank work type' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when depositing with blank work type' do
      it 'is invalid' do
        expect(form.valid?(deposit: true)).to be false
        expect(form.errors[:work_type]).to include("can't be blank")
      end
    end

    context 'when Other work type and blank other work subtype' do
      let(:work_type) { 'Other' }

      it 'is invalid' do
        expect(form.valid?(deposit: true)).to be false
        expect(form.errors[:other_work_subtype]).to include("can't be blank")
      end
    end

    context 'when Other work type and other work subtype' do
      let(:work_type) { 'Other' }
      let(:other_work_subtype) { 'baseball cards' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when Music work type and no work subtypes' do
      let(:work_type) { 'Music' }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:work_subtypes]).to include('1 term is the minimum allowed')
      end
    end

    context 'when Music work type and one work subtype' do
      let(:work_type) { 'Music' }
      let(:work_subtypes) { ['Album'] }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when Mixed Materials work type and no work subtypes' do
      let(:work_type) { 'Mixed Materials' }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:work_subtypes]).to include('2 terms is the minimum allowed')
      end
    end

    context 'when Mixed Materials work type and two work subtypes' do
      let(:work_type) { 'Mixed Materials' }
      let(:work_subtypes) { %w[Animation Article] }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end
end
