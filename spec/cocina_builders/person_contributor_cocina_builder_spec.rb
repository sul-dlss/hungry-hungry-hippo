# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonContributorCocinaBuilder do
  subject(:contributor_params) do
    described_class.call(forename: 'Leland', surname: 'Stanford', role: 'funder', orcid:, cited:)
  end

  let(:orcid) { '' }
  let(:cited) { true }

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

  context 'when cited' do
    it 'does not include note' do
      expect(contributor_params[:note]).to be_nil
    end
  end

  context 'when not cited' do
    let(:cited) { false }

    it 'include notes' do
      expect(contributor_params[:note]).to eq([{ type: 'citation status', value: 'false' }])
    end
  end
end
