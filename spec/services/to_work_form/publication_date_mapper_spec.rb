# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::PublicationDateMapper do
  subject(:event_date) { described_class.call(cocina_object:) }

  let(:cocina_object) do
    # NOTE: the :dro factory in the cocina-models gem does not have a seam
    #       for injecting abstract, so we do it manually here
    build(:dro).then do |object|
      object.new(
        object
        .to_h
        .tap do |obj|
          obj[:description][:event] =
            [
              event
            ]
        end
      )
    end
  end

  context 'when event date is EDTF with year only' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'publication', date: '2021')
    end

    it 'returns the event date' do
      expect(event_date).to eq(year: 2021, approximate: false)
    end
  end

  context 'when event date is EDTF with year and month only' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'publication', date: '2021-03')
    end

    it 'returns the event date' do
      expect(event_date).to eq(year: 2021, month: 3, approximate: false)
    end
  end

  context 'when event date is approximate EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'publication', date: '2021-03~')
    end

    it 'returns the event date' do
      expect(event_date).to eq(year: 2021, month: 3, approximate: true)
    end
  end

  context 'when event date is EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'publication', date: '2021-03-05')
    end

    it 'returns the event date' do
      expect(event_date).to eq(year: 2021, month: 3, day: 5, approximate: false)
    end
  end

  context 'when event date is not EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'publication', date: '2021-03-05', date_encoding_code: 'iso8601')
    end

    it 'returns nil' do
      expect(event_date).to eq({})
    end
  end

  context 'when event date is not correct type' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'deposit', date: '2021-03-05')
    end

    it 'returns nil' do
      expect(event_date).to eq({})
    end
  end
end
