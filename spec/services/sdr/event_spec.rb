# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::Event do
  let(:druid) { 'druid:bc123df4567' }

  describe '#create' do
    let(:event_type) { 'test_event' }
    let(:event_data) { { key: 'value' } }

    context 'when rabbitmq is enabled' do
      before do
        allow(Settings.rabbitmq).to receive(:enabled).and_return(true)
        allow(Dor::Event::Client).to receive(:create)
      end

      it 'creates an event for the object' do
        described_class.create(druid:, type: event_type, data: event_data)

        expect(Dor::Event::Client).to have_received(:create).with(druid:, type: event_type, data: event_data)
      end
    end

    context 'when rabbitmq is not enabled' do
      before do
        allow(Dor::Event::Client).to receive(:create)
      end

      it 'does not create an event for the object' do
        described_class.create(druid:, type: event_type, data: event_data)

        expect(Dor::Event::Client).not_to have_received(:create)
      end
    end

    context 'when creating the event fails' do
      before do
        allow(Settings.rabbitmq).to receive(:enabled).and_return(true)
        allow(Dor::Event::Client).to receive(:create).and_raise(StandardError, 'Failed to create event')
      end

      it 'raises an error' do
        expect { described_class.create(druid:, type: event_type, data: event_data) }.to raise_error(Sdr::Event::Error)
      end
    end
  end

  describe '#list' do
    context 'when listing events succeeds' do
      let(:events) { [instance_double(Dor::Services::Client::Events::Event)] }
      let(:event_client) { instance_double(Dor::Services::Client::Events, list: events) }

      before do
        allow(Dor::Services::Client.object(druid)).to receive(:events).and_return(event_client)
      end

      it 'returns the list of events' do
        expect(described_class.list(druid:)).to eq(events)
        expect(event_client).to have_received(:list).with(event_types: Sdr::Event::EVENT_TYPES)
      end
    end

    context 'when listing events fails' do
      before do
        allow(Dor::Services::Client.object(druid)).to receive(:events).and_raise(Dor::Services::Client::Error,
                                                                                 'Failed to list events')
      end

      it 'raises an error' do
        expect { described_class.list(druid:) }.to raise_error(Sdr::Event::Error)
      end
    end
  end
end
