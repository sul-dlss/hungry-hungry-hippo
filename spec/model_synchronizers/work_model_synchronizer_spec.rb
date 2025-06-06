# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkModelSynchronizer do
  let(:druid) { druid_fixture }
  let(:collection) { create(:collection, :with_druid) }
  let(:new_collection) { create(:collection, :with_druid) }
  let(:work) { create(:work, druid:, collection:) }
  let(:cocina_object) do
    Cocina::Models.with_metadata(build(:dro, id: druid, title: title_fixture, collection_ids: [new_collection.druid],
                                             version: 2),
                                 lock_fixture, modified: Time.current)
  end

  it 'updates the work' do
    expect { described_class.call(work:, cocina_object:) }
      .to change { work.reload.title }.to(title_fixture)
      .and change(work, :collection).to(new_collection)
      .and change(work, :object_updated_at).to(cocina_object.modified)
      .and change(work, :version).to(2)
  end

  context 'when the collection is not found' do
    let(:cocina_object) do
      build(:dro_with_metadata, id: druid, title: title_fixture, collection_ids: [collection_druid_fixture])
    end

    it 'raises an error' do
      expect { described_class.call(work:, cocina_object:) }
        .to raise_error(WorkModelSynchronizer::Error)
    end
  end

  context 'when the collection is not found and raise is false' do
    let(:cocina_object) do
      build(:dro_with_metadata, id: druid, title: title_fixture, collection_ids: [collection_druid_fixture])
    end

    it 'does not raise an error' do
      expect { described_class.call(work:, cocina_object:, raise: false) }
        .to change { work.reload.title }.to(title_fixture)
    end
  end
end
