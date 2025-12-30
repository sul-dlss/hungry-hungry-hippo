# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::WorkKeywordsMapper do
  context 'when object has keywords' do
    let(:cocina_object) do
      # NOTE: the :dro factory in the cocina-models gem does not have a seam
      #       for injecting keywords, so we do it manually here
      build(:dro, title: title_fixture).then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
              obj[:description][:subject] = [
                {
                  value: keywords_fixture.first['text'],
                  type: keywords_fixture.first['cocina_type'],
                  uri: keywords_fixture.first['uri']
                },
                {
                  value: keywords_fixture.second['text']
                }
              ]
          end
        )
      end
    end

    it 'returns the keywords' do
      expect(described_class.call(cocina_object:)).to eq keywords_fixture
    end
  end

  context 'when object has no keywords' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns nil' do
      expect(described_class.call(cocina_object:)).to be_nil
    end
  end
end
