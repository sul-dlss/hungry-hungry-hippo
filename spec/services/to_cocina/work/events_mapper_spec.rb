# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::EventsMapper do
  describe 'publication events' do
    subject(:events) { described_class.call(work_form:) }

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
  end
end
