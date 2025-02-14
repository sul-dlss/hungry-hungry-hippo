# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MoveTargetCollections do
  subject(:target_collections) { described_class.call(work_form:) }

  let(:work_form) do
    WorkForm.new(
      release_option:,
      doi_option:,
      access:,
      license:,
      collection_druid: this_collection.druid
    )
  end

  let(:release_option) { 'immediate' }
  let(:doi_option) { 'yes' }
  let(:access) { 'world' }
  let(:license) { nil }
  let(:this_collection) { create(:collection, :with_druid) }

  it 'excludes the current collection' do
    expect(target_collections).not_to include(this_collection)
  end

  describe 'embargoes' do
    let!(:depositor_selects_collection) { create(:collection, :with_druid, release_option: 'depositor_selects') }
    let!(:immediate_collection) { create(:collection, :with_druid, release_option: 'immediate') }

    context 'when the work is embargoed' do
      let(:release_option) { 'delay' }

      it 'does not include immediate release only collections' do
        expect(target_collections).not_to include(immediate_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end

    context 'when the work is not embargoed' do
      it 'includes immediate release only collections' do
        expect(target_collections).to include(immediate_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end
  end

  describe 'DOI options' do
    let!(:yes_collection) { create(:collection, :with_druid, doi_option: 'yes') }
    let!(:no_collection) { create(:collection, :with_druid, doi_option: 'no') }
    let!(:depositor_selects_collection) { create(:collection, :with_druid, doi_option: 'no') }

    context 'when the work does not have a DOI' do
      let(:doi_option) { 'no' }

      it 'does not include collections that require a DOI' do
        expect(target_collections).not_to include(yes_collection)
        expect(target_collections).to include(no_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end

    context 'when the work does have a DOI' do
      it 'includes collections that require a DOI' do
        expect(target_collections).to include(yes_collection)
        expect(target_collections).to include(no_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end
  end

  describe 'access' do
    let!(:world_collection) { create(:collection, :with_druid, access: 'world') }
    let!(:stanford_collection) { create(:collection, :with_druid, access: 'stanford') }

    context 'when the work is stanford access' do
      let(:access) { 'stanford' }

      it 'does not include collections that require world visibility' do
        expect(target_collections).not_to include(world_collection)
        expect(target_collections).to include(stanford_collection)
      end
    end

    context 'when the work is world access' do
      it 'includes collections that require world visibility' do
        expect(target_collections).to include(world_collection)
        expect(target_collections).to include(stanford_collection)
      end
    end
  end

  describe 'license' do
    let(:collection_license) { 'https://creativecommons.org/licenses/by/4.0/legalcode' }
    let!(:required_collection) do
      create(:collection, :with_druid, license_option: 'required', license: collection_license)
    end
    let!(:depositor_selects_collection) { create(:collection, :with_druid, license_option: 'depositor_selects') }

    context 'when the work has a license that is different than the require license' do
      let(:license) { 'https://creativecommons.org/licenses/by/3.0/legalcode' }

      it 'does not include collections that require a different license' do
        expect(target_collections).not_to include(required_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end

    context 'when the work has a license that is the same as the required license' do
      let(:license) { collection_license }

      it 'includes collections that require a different license' do
        expect(target_collections).to include(required_collection)
        expect(target_collections).to include(depositor_selects_collection)
      end
    end
  end
end
