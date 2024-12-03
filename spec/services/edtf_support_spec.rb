# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EdtfSupport do
  describe '#to_edtf_s' do
    context 'when year is not provided' do
      it 'returns nil' do
        expect(described_class.to_edtf_s(year: nil, month: 1, day: 2)).to be_nil
      end
    end

    context 'when a year, month, and day are provided' do
      it 'returns an EDTF date string' do
        expect(described_class.to_edtf_s(year: 2021, month: 1, day: 2)).to eq('2021-01-02')
      end
    end

    context 'when a year and month are provided' do
      it 'returns an EDTF date string' do
        expect(described_class.to_edtf_s(year: 2021, month: 1)).to eq('2021-01')
      end
    end

    context 'when only a year is provided' do
      it 'returns an EDTF date string' do
        expect(described_class.to_edtf_s(year: 2021)).to eq('2021')
      end
    end
  end
end
