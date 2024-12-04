# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateForm do
  describe '.to_edtf_s' do
    it 'returns the date as an EDTF string' do
      expect(described_class.new(year: 2021, month: 3, day: 5).to_edtf_s).to eq '2021-03-05'
    end
  end

  describe 'validations' do
    let(:form) { described_class.new(year:, month:, day:) }
    let(:year) { '' }
    let(:month) { '' }
    let(:day) { '' }

    context 'when all nil' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when year only' do
      let(:year) { '2021' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when year and month only' do
      let(:year) { '2021' }
      let(:month) { '3' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when year, month, and day' do
      let(:year) { '2021' }
      let(:month) { '3' }
      let(:day) { '5' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when year is less than 1000' do
      let(:year) { '999' }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end

    context 'when year is greater than the current year' do
      let(:year) { (Time.zone.now.year + 1).to_s }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end

    context 'when month but not year' do
      let(:month) { '3' }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end

    context 'when day but not month' do
      let(:year) { '2021' }
      let(:day) { '5' }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end
  end
end
