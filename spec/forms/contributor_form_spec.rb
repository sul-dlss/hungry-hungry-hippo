# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributorForm do
  describe 'validations' do
    let(:form) do
      described_class.new(role_type:, person_role:, organization_role:, first_name:, last_name:,
                          with_orcid:, orcid:, organization_name:, affiliations_attributes:)
    end

    let(:role_type) { 'person' }
    let(:person_role) { 'author' }
    let(:organization_role) { '' }
    let(:with_orcid) { false }
    let(:orcid) { '' }
    let(:first_name) { '' }
    let(:last_name) { '' }
    let(:organization_name) { '' }
    let(:affiliations_attributes) { [] }

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
      let(:first_name) { 'Jane' }
      let(:last_name) { 'Stanford' }

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

    context 'when an author affiliation is provided' do
      let(:affiliations_attributes) do
        [
          {
            institution: 'Stanford University',
            uri: 'https://ror.org/01abcd',
            department: 'Department of History'
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when an invalid author affiliation is provided' do
      let(:affiliations_attributes) do
        [
          {
            institution: 'Stanford University',
            department: 'Department of History'
          }
        ]
      end

      it 'is not valid' do
        expect(form).not_to be_valid
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
        expect(form.valid?(:deposit)).not_to be true
      end
    end

    context 'when ORCID format is not valid' do
      let(:orcid) { 'ABCD' }
      let(:with_orcid) { true }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:orcid]).to eq(['must be formatted as "XXXX-XXXX-XXXX-XXXX"'])
      end
    end

    context 'when depositing and missing part of a name' do
      let(:first_name) { 'Jane' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors.size).to eq(1)
        expect(form.errors[:last_name]).to eq(['must provide a last name'])
      end
    end

    context 'when depositing and missing name' do
      let(:first_name) { '' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors.size).to eq(2)
        expect(form.errors[:first_name]).to eq(['must provide a first name'])
        expect(form.errors[:last_name]).to eq(['must provide a last name'])
      end
    end

    context 'when depositing with orcid and missing orcid' do
      let(:with_orcid) { true }
      let(:first_name) { '' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors.size).to eq(1)
        error = form.errors.first
        expect(error.attribute).to eq(:orcid)
        expect(error.message).to eq("can't be blank")
        # Note that not validating first and last name because orcid is not present.
      end
    end

    context 'when with orcid and missing orcid' do
      let(:with_orcid) { true }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when with orcid and missing both names' do
      let(:with_orcid) { true }
      let(:orcid) { '0000-0000-0000-0000' }
      let(:first_name) { '' }
      let(:last_name) { '' }

      it 'is not valid' do
        expect(form.valid?(:deposit)).to be false
      end
    end

    context 'when with orcid and missing last name' do
      let(:with_orcid) { true }
      let(:orcid) { '0000-0000-0000-0000' }
      let(:first_name) { 'Jane' }
      let(:last_name) { '' }

      it 'is valid' do
        expect(form.valid?(:deposit)).to be true
      end
    end
  end
end
