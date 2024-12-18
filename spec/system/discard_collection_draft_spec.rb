# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discard a collection draft' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }
  let!(:collection) { create(:collection, druid:, title: collection_title_fixture, user:) }
  let(:cocina_object) { collection_with_metadata_fixture }

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
      visit collection_path(druid)

      expect(page).to have_css('h1', text: collection.title)
      expect(page).to have_css('.status', text: 'New version in draft')
      expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))
      accept_confirm 'Are you sure?' do
        click_on('Discard draft')
      end

      expect(page).to have_current_path(collection_path(druid))
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

    before do
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    end

    it 'destroys the work' do
      visit collection_path(druid)

      expect(page).to have_css('h1', text: collection.title)
      expect(page).to have_css('.status', text: 'Draft - Not deposited')
      expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))
      accept_confirm 'Are you sure?' do
        click_on('Discard draft')
      end

      expect(page).to have_no_button('Discard draft')
      expect(page).to have_css('.alert-success', text: 'Draft discarded.')
      expect(page).to have_current_path(root_path)

      expect(Collection.find_by(druid:)).to be_nil
    end
  end
end
