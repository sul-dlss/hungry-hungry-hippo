# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkFormSerializer do
  let(:serialized_form) do
    {
      '_aj_serialized' => 'WorkFormSerializer',
      'attributes' => {
        'title' => 'My Title',
        'druid' => druid,
        'version' => 1,
        'lock' => nil
      }
    }
  end

  let(:druid) { 'druid:bc123df4567' }

  let(:work_form) { WorkForm.new(title: 'My Title', druid:) }

  describe '.serialize?' do
    context 'with a Work Form' do
      it 'returns true' do
        expect(described_class.serialize?(WorkForm.new)).to be true
      end
    end

    context 'with something other than a Work Form' do
      it 'returns false' do
        expect(described_class.serialize?(ApplicationForm.new)).to be false
      end
    end
  end

  describe '.serialize' do
    it 'serializes a Work Form' do
      expect(described_class.serialize(work_form)).to eq(serialized_form)
    end
  end

  describe '.deserialize' do
    it 'deserializes a Work Form' do
      expect(described_class.deserialize(serialized_form).attributes).to eq(work_form.attributes)
    end
  end
end
