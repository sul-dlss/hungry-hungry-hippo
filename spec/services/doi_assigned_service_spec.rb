# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DoiAssignedService do
  include WorkMappingFixtures
  subject(:assigned?) { described_class.call(work:, cocina_object:) }

  let(:work) { create(:work, doi_assigned: false) }

  let(:cocina_object) do
    dro_fixture
  end

  context 'when the cocina object does not have a DOI' do
    let(:cocina_object) do
      dro_fixture.new(identification: { sourceId: source_id_fixture })
    end

    it { is_expected.to be false }
  end

  context 'when the work record indicates that the DOI is assigned' do
    let(:work) { create(:work, doi_assigned: true) }

    it { is_expected.to be true }
  end

  context 'when Datacite returns that the DOI is not assigned' do
    before do
      allow(Doi).to receive(:assigned?).with(druid: work.druid).and_return(false)
    end

    it { is_expected.to be false }
  end

  context 'when Datacite returns that the DOI is assigned' do
    before do
      allow(Doi).to receive(:assigned?).with(druid: work.druid).and_return(true)
    end

    it 'updates the work record' do
      expect { assigned? }.to change { work.reload.doi_assigned }.from(false).to(true)
    end

    it { is_expected.to be true }
  end
end
