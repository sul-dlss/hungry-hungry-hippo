# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EdtfDate do
  subject(:date) { described_class.new(year:, month:, day:, approximate:).to_date }

  let(:year) { 2021 }
  let(:month) { 1 }
  let(:day) { nil }
  let(:approximate) { false }

  describe '#to_s' do
    context 'when year is not provided' do
      let(:year) { nil }

      it 'returns nil' do
        expect(date).to be_nil
      end
    end

    context 'when a year, month, and day are provided' do
      let(:day) { 2 }

      it 'returns an EDTF date string' do
        expect(date.to_fs(:edtf)).to eq('2021-01-02')
      end
    end

    context 'when a year and month are provided' do
      it 'returns an EDTF date string' do
        expect(date.to_fs(:edtf)).to eq('2021-01')
      end
    end

    context 'when only a year is provided' do
      let(:month) { nil }

      it 'returns an EDTF date string' do
        expect(date.to_fs(:edtf)).to eq('2021')
      end
    end

    context 'when approximate' do
      let(:approximate) { true }

      it 'returns an approximate EDTF date string' do
        expect(date.to_fs(:edtf)).to eq('2021-01~')
      end
    end
  end
end
