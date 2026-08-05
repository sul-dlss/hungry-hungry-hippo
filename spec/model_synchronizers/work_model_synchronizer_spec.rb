# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkModelSynchronizer do
  let(:druid) { druid_fixture }
  let(:collection) { create(:collection, :with_druid) }
  let(:new_collection) { create(:collection, :with_druid) }
  let(:work) { create(:work, druid:, collection:) }
  let(:most_recent_timestamp) { '2025-06-15T12:00:00.000Z' }
  let(:events) do
    [
      Dor::Services::Client::Events::Event.new(event_type: 'version_close', timestamp: most_recent_timestamp,
                                               data: {}),
      Dor::Services::Client::Events::Event.new(event_type: 'registration', timestamp: '2025-01-01T00:00:00.000Z',
                                               data: {})
    ]
  end
  let(:cocina_object) do
    Cocina::Models.with_metadata(build(:dro, id: druid, title: title_fixture, collection_ids: [new_collection.druid],
                                             version: 2),
                                 lock_fixture, modified: Time.current)
  end

  before do
    allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)
  end

  it 'updates the work with the most recent event timestamp' do
    expect { described_class.call(work:, cocina_object:) }
      .to change { work.reload.title }.to(title_fixture)
      .and change(work, :collection).to(new_collection)
      .and change(work, :object_updated_at).to(Time.zone.parse(most_recent_timestamp))
      .and change(work, :version).to(2)
  end

  context 'when there are no events' do
    let(:events) { [] }

    it 'falls back to cocina_object modified' do
      expect { described_class.call(work:, cocina_object:) }
        .to change { work.reload.object_updated_at }.to(cocina_object.modified)
    end
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
