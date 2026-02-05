# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonContributorCocinaBuilder do
  subject(:contributor_params) do
    described_class.call(forename: 'Leland', surname: 'Stanford', role: 'funder', orcid:, affiliations:)
  end

  let(:orcid) { '' }
  let(:affiliations) { [] }

  context 'when orcid is blank' do
    it 'does not include identifier' do
      expect(contributor_params[:identifier]).to be_nil
    end
  end

  context 'when orcid is nil' do
    let(:orcid) { nil }

    it 'does not include identifier' do
      expect(contributor_params[:identifier]).to be_nil
    end
  end

  context 'when orcid' do
    let(:orcid) { '0000-0000-0000-0000' }

    it 'does not include identifier' do
      expect(contributor_params[:identifier]).to eq [{ value: '0000-0000-0000-0000', type: 'ORCID',
                                                       source: { uri: 'https://orcid.org' } }]
    end
  end

  context 'when affiliations are present' do
    context 'when a department is present' do
      let(:affiliations) do
        [
          AffiliationForm.new(
            institution: 'Stanford University',
            uri: 'https://ror.org/01abcd',
            department: 'Department of History'
          )
        ]
      end

      it 'includes affiliations' do
        expected_affiliations = [
          {
            structuredValue: [
              {
                value: 'Stanford University',
                identifier: [
                  {
                    uri: 'https://ror.org/01abcd',
                    type: 'ROR',
                    source: { code: 'ror' }
                  }
                ]
              },
              { value: 'Department of History' }
            ]
          }
        ]

        expect(contributor_params[:affiliation]).to eq(expected_affiliations)
      end
    end

    context 'when a department is not present' do
      let(:affiliations) do
        [
          AffiliationForm.new(
            institution: 'Stanford University',
            uri: 'https://ror.org/01abcd'
          )
        ]
      end

      it 'includes affiliations in the note' do
        expected_affiliations = [
          {
            structuredValue: [
              {
                value: 'Stanford University',
                identifier: [
                  {
                    uri: 'https://ror.org/01abcd',
                    type: 'ROR',
                    source: { code: 'ror' }
                  }
                ]
              }
            ]
          }
        ]

        expect(contributor_params[:affiliation]).to eq(expected_affiliations)
      end
    end

    context 'when ROR URI is not present' do
      let(:affiliations) do
        [
          AffiliationForm.new(
            institution: 'Stanford University'
          )
        ]
      end

      it 'includes affiliations' do
        expected_affiliations = [
          {
            structuredValue: [
              {
                value: 'Stanford University'
              }
            ]
          }
        ]

        expect(contributor_params[:affiliation]).to eq(expected_affiliations)
      end
    end
  end
end
