# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerators::Description::PersonContributor do
  subject(:contributor_params) { described_class.call(forename: 'Leland', surname: 'Stanford', role: 'funder', orcid:) }

  context 'when orcid is blank' do
    let(:orcid) { '' }

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
                                                       source: { uri: 'https://orcid.org/' } }]
    end
  end
end
