# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::CreationDateMapper do
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
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_single_attributes: {
                                 year: 2021,
                                 approximate: false
                               },
                               create_date_type: 'single')
    end
  end

  context 'when event date is EDTF with year and month only' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_single_attributes: {
                                 year: 2021,
                                 month: 3,
                                 approximate: false
                               },
                               create_date_type: 'single')
    end
  end

  context 'when event date is approximate EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03~')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_single_attributes: {
                                 year: 2021,
                                 month: 3,
                                 approximate: true
                               },
                               create_date_type: 'single')
    end
  end

  context 'when event date is EDTF interval' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03~/2021-04-21')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_range_from_attributes: {
                                 year: 2021,
                                 month: 3,
                                 approximate: true
                               },
                               create_date_range_to_attributes: {
                                 year: 2021,
                                 month: 4,
                                 day: 21,
                                 approximate: false
                               },
                               create_date_type: 'range')
    end
  end

  context 'when event date is EDTF interval with both dates approximate' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03~/2021-04~')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_range_from_attributes: {
                                 year: 2021,
                                 month: 3,
                                 approximate: true
                               },
                               create_date_range_to_attributes: {
                                 year: 2021,
                                 month: 4,
                                 approximate: true
                               },
                               create_date_type: 'range')
    end
  end

  context 'when event date is EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-05')
    end

    it 'returns the event date' do
      expect(event_date).to eq(create_date_single_attributes: {
                                 year: 2021,
                                 month: 3,
                                 day: 5,
                                 approximate: false
                               },
                               create_date_type: 'single')
    end
  end

  context 'when event date is not EDTF' do
    let(:event) do
      DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-05', date_encoding_code: 'iso8601')
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
