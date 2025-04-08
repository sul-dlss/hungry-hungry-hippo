# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventCocinaBuilder do
  subject(:event) do
    described_class.call(type:, date:, date_encoding_code:, primary:, date_type:)
  end

  let(:type) { 'publication' }
  let(:date_encoding_code) { 'edtf' }
  let(:primary) { false }
  let(:date) { Date.new(2024, 3).tap { |d| d.precision = :month } }
  let(:date_type) { nil }

  context 'when date is a string' do
    let(:date) { '2024-03' }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            value: '2024-03',
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end

  context 'when date is nil' do
    let(:date) { nil }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication'
      )
    end
  end

  context 'when date is an EDTF date' do
    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            value: '2024-03',
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end

  context 'when date is primary' do
    let(:primary) { true }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',

        date: [
          {
            value: '2024-03',
            type: 'publication',
            encoding: { code: 'edtf' },
            status: 'primary'
          }
        ]
      )
    end
  end

  context 'when date is approximate' do
    before do
      date.approximate!
    end

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            value: '2024-03',
            type: 'publication',
            encoding: { code: 'edtf' },
            qualifier: 'approximate'
          }
        ]
      )
    end
  end

  context 'when date type is provided' do
    let(:type) { 'deposit' }
    let(:date_type) { 'publication' }

    it 'returns the event' do
      expect(event).to match(
        type: 'deposit',
        date: [
          {
            value: '2024-03',
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end

  context 'when date is an interval' do
    let(:date) { Date.edtf('2024-03-01/2024-03-31') }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            structuredValue: [
              {
                value: '2024-03-01',
                type: 'start'

              },
              {
                value: '2024-03-31',
                type: 'end'
              }
            ],
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end

  context 'when date is an interval with one approximate date' do
    let(:date) { Date.edtf('2024~/2024-03-31') }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            structuredValue: [
              {
                value: '2024',
                type: 'start',
                qualifier: 'approximate'
              },
              {
                value: '2024-03-31',
                type: 'end'
              }
            ],
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end

  context 'when date is an interval with both approximate dates' do
    let(:date) { Date.edtf('2024~/2024-03~') }

    it 'returns the event' do
      expect(event).to match(
        type: 'publication',
        date: [
          {
            structuredValue: [
              {
                value: '2024',
                type: 'start'
              },
              {
                value: '2024-03',
                type: 'end'
              }
            ],
            qualifier: 'approximate',
            type: 'publication',
            encoding: { code: 'edtf' }
          }
        ]
      )
    end
  end
end
