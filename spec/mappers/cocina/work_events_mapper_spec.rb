# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::WorkEventsMapper do
  subject(:events) { described_class.call(work_form:) }

  describe 'publication events' do
    context 'when no publication date' do
      let(:work_form) { WorkForm.new }

      it 'returns an empty array' do
        expect(events).to eq([])
      end
    end

    context 'when publication date' do
      let(:work_form) { WorkForm.new(publication_date_attributes:) }

      let(:publication_date_attributes) { { year: 2021, month: 1, day: 11 } }

      it 'maps to cocina' do
        expect(events).to eq([
                               {
                                 type: 'publication',
                                 date: [
                                   {
                                     value: '2021-01-11',
                                     type: 'publication',
                                     encoding: { code: 'edtf' },
                                     status: 'primary'
                                   }
                                 ]
                               }
                             ])
      end
    end

    context 'when deposit publication date' do
      let(:work_form) { WorkForm.new(deposit_publication_date: Date.new(2021, 1, 11)) }

      it 'maps to cocina' do
        expect(events).to eq([
                               {
                                 type: 'deposit',
                                 date: [
                                   {
                                     value: '2021-01-11',
                                     type: 'publication',
                                     encoding: { code: 'edtf' }
                                   }
                                 ]
                               }
                             ])
      end
    end
  end

  describe 'create date events' do
    context 'when creation date range' do
      let(:work_form) do
        WorkForm.new(
          create_date_range_from_attributes: creation_date_range_from_fixture,
          create_date_range_to_attributes: creation_date_range_to_fixture,
          create_date_type: 'range'
        )
      end

      it 'maps to cocina' do
        expect(events).to eq([
                               { type: 'creation',
                                 date: [
                                   { encoding: { code: 'edtf' },
                                     type: 'creation',
                                     structuredValue: [
                                       { value: '2021-03-07', type: 'start' },
                                       { value: '2022-04', type: 'end', qualifier: 'approximate' }
                                     ] }
                                 ] }
                             ])
      end
    end

    context 'when cleared creation date range' do
      let(:work_form) do
        WorkForm.new(
          create_date_range_from_attributes: empty_date_range_attributes,
          create_date_range_to_attributes: empty_date_range_attributes,
          create_date_type: 'range'
        )
      end

      let(:empty_date_range_attributes) do
        {
          'year' => nil,
          'month' => nil,
          'day' => nil,
          'approximate' => false
        }
      end

      it 'maps to cocina' do
        expect(events).to eq([])
      end
    end
  end
end
