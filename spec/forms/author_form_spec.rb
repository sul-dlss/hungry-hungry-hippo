# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorForm do
  describe 'validations' do
    let(:form) do
      described_class.new(role_type:, person_role:, organization_role:, first_name:, last_name:,
                          with_orcid:, orcid:, organization_name:)
    end

    let(:role_type) { 'person' }
    let(:person_role) { 'author' }
    let(:organization_role) { '' }
    let(:with_orcid) { false }
    let(:orcid) { '' }
    let(:first_name) { '' }
    let(:last_name) { '' }
    let(:organization_name) { '' }

    context 'when empty form' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when all person fields provided' do
      let(:first_name) { 'Jane' }
      let(:last_name) { 'Stanford' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when person with ORCID' do
      let(:with_orcid) { true }
      let(:orcid) { '0000-0000-0000-0000' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when all organization fields' do
      let(:role_type) { 'organization' }
      let(:person_role) { '' }
      let(:organization_role) { 'author' }
      let(:organization_name) { 'Stanford University' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when missing first name' do
      let(:first_name) { '' }
      let(:last_name) { 'Stanford' }

      it 'is not valid' do
        expect(form).not_to be_valid
      end
    end

    context 'when missing last name' do
      let(:first_name) { 'Jane' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form).not_to be_valid
      end
    end

    context 'when missing organization name' do
      let(:role_type) { 'organization' }
      let(:person_role) { '' }
      let(:organization_role) { 'author' }
      let(:organization_name) { '' }

      it 'is not valid' do
        expect(form.valid?(deposit: true)).not_to be true
      end
    end

    context 'when ORCID is not a URL' do
      let(:orcid) { '0000-0000-0000-0000' }
      let(:with_orcid) { true }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when ORCID format is not valid' do
      let(:orcid) { 'ABCD' }

      it 'is not valid' do
        expect(form).not_to be_valid
      end
    end

    context 'when depositing and missing name' do
      let(:first_name) { '' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form.valid?(deposit: true)).to be false
      end
    end
  end
end
