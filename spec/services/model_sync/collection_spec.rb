# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelSync::Collection do
  let(:druid) { druid_fixture }
  let(:collection) { create(:collection, :with_druid) }
  # let(:new_collection) { create(:collection, :with_druid) }
  # let(:work) { create(:work, druid:, collection:) }
  let(:cocina_object) do
    Cocina::Models.with_metadata(build(:collection, id: druid, title: collection_title_fixture),
                                 lock_fixture, modified: Time.current)
  end

  it 'updates the collection' do
    expect { described_class.call(collection:, cocina_object:) }
      .to change { collection.reload.title }.to(collection_title_fixture)
      .and change(collection, :object_updated_at).to(cocina_object.modified)
  end
end
