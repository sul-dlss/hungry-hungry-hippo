# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discard a work draft' do
  include WorkMappingFixtures
  include CollectionMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, user:) }
  let(:cocina_object) { dro_with_metadata_fixture }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:discard_draft)

    sign_in(user)
  end

  context 'when not the first version' do
    let(:version_status_discardable) do
      VersionStatus.new(status:
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 2, discardable?: true,
                                                                           openable?: false))
    end
    let(:version_status_openable) do
      VersionStatus.new(status:
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                           discardable?: false,
                                                                           openable?: true, accessioning?: false))
    end

    before do
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status_discardable,
                                                                         version_status_openable)
    end

    it 'discards a draft' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('.status', text: 'New version in draft')
      expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
      accept_confirm(/Are you sure/) do
        click_on('Discard draft')
      end

      expect(page).to have_current_path(work_path(druid))
      expect(page).to have_no_button('Discard draft')
      expect(page).to have_css('.alert-success', text: 'Draft discarded.')
      expect(page).to have_css('.status', text: 'Deposited')
    end
  end

  context 'when the first version' do
    let(:version_status) do
      VersionStatus.new(status:
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 1, discardable?: false,
                                                                           openable?: false))
    end

    let(:collection_cocina_object) { collection_with_metadata_fixture }

    before do
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:status).with(druid: collection.druid).and_return(version_status)
      allow(Sdr::Repository).to receive(:find).with(druid: collection.druid).and_return(collection_cocina_object)
    end

    it 'destroys the work' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('.status', text: 'Draft - Not deposited')
      expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
      accept_confirm(/Are you sure/) do
        click_on('Discard draft')
      end

      expect(page).to have_current_path(work_path(druid))
      expect(page).to have_no_button('Discard draft')
      expect(page).to have_css('.alert-success', text: 'Draft discarded.')
      expect(page).to have_current_path(collection_path(druid: collection.druid))

      expect(Work.find_by(druid:)).to be_nil
    end
  end
end