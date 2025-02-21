# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MoveForm do
  subject(:form) { described_class.new(collection_druid:, work_form:) }

  let(:collection_druid) { collection.druid }

  let(:collection) do
    create(:collection, :with_druid,
           release_option: 'immediate',
           doi_option: 'yes',
           license_option: 'required',
           license: 'https://creativecommons.org/licenses/by/4.0/legalcode',
           access: 'world')
  end

  let(:work_form) do
    WorkForm.new(
      release_option: work_release_option,
      doi_option: work_doi_option,
      license: work_license,
      access: work_access,
      collection_druid: work_collection_druid
    )
  end
  let(:work_release_option) { 'immediate' }
  let(:work_doi_option) { 'yes' }
  let(:work_license) { 'https://creativecommons.org/licenses/by/4.0/legalcode' }
  let(:work_access) { 'world' }
  let(:work_collection_druid) { collection_druid_fixture }

  describe 'validations' do
    context 'when collection is a move target' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when druid is without prefix and collection is a move target' do
      let(:collection_druid) { collection.druid.delete_prefix('druid:') }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when collection is blank' do
      let(:collection_druid) { '' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(["can't be blank"])
      end
    end

    context 'when collection is missing' do
      let(:collection_druid) { collection_druid_fixture }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['not found'])
      end
    end

    context 'when already part of that collection' do
      let(:work_collection_druid) { collection_druid }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['already part of this collection'])
      end
    end

    context 'when collection is immediate release but work is embargoed' do
      let(:work_release_option) { 'delay' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['work is embargoed but collection is immediate release only'])
      end
    end

    context 'when work DOI option is no but collection DOI option is yes' do
      let(:work_doi_option) { 'no' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['work is not set for DOI assignment but collection requires ' \
                                                      'DOI assignment'])
      end
    end

    context 'when collection license is required by work has a different license' do
      let(:work_license) { 'https://creativecommons.org/licenses/by/3.0/legalcode' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['work has a license that is not allowed by the collection'])
      end
    end

    context 'when collection access is world but work access is stanford' do
      let(:work_access) { 'stanford' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:collection_druid]).to eq(['work is set for Stanford visibility but the collection ' \
                                                      'requires world visibility'])
      end
    end
  end
end
