# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelatedLinksMapper do
  context 'when object has related links' do
    let(:cocina_object) do
      # NOTE: the :dro factory in the cocina-models gem does not have a seam
      #       for injecting related links, so we do it manually here
      build(:dro, title: title_fixture).then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
            obj[:description][:relatedResource] = [
              {
                access: {
                  url: [{ value: related_links_fixture.first['url'] }]
                },
                title: [{ value: related_links_fixture.first['text'] }]
              },
              {
                purl: related_links_fixture.second['url'],
                title: [{ value: related_links_fixture.second['text'] }]
              }
            ]
          end
        )
      end
    end

    it 'returns the related links' do
      expect(described_class.call(cocina_object:)).to eq related_links_fixture
    end
  end

  context 'when object has no related links' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns nil' do
      expect(described_class.call(cocina_object:)).to be_nil
    end
  end
end
