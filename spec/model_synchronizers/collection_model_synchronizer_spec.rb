# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionModelSynchronizer do
  let(:druid) { druid_fixture }
  let(:collection) { create(:collection, :with_druid) }
  let(:cocina_object) do
    Cocina::Models.with_metadata(build(:collection, id: druid, title: collection_title_fixture, version: 2),
                                 lock_fixture, modified: Time.current)
  end

  it 'updates the collection' do
    expect { described_class.call(collection:, cocina_object:) }
      .to change { collection.reload.title }.to(collection_title_fixture)
      .and change(collection, :object_updated_at).to(cocina_object.modified)
      .and change(collection, :version).to(2)
  end
end
