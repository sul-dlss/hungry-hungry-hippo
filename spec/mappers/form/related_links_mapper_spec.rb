# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelatedLinksMapper do
  context 'when object has related links' do
    let(:cocina_object) do
      # NOTE: the :collection factory in the cocina-models gem does not have a seam
      #       for injecting related links, so we do it manually here
      build(:collection, title: title_fixture).then do |object|
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

  context 'when the object has a related link with a URI' do
    let(:cocina_object) do
      # NOTE: the :collection factory in the cocina-models gem does not have a seam
      #       for injecting related links, so we do it manually here
      build(:collection, title: title_fixture).then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
              obj[:description][:relatedResource] = [
                {
                  identifier: [{ uri: 'https://doi.org/10.1234/5678', type: 'doi' }],
                  title: [{ value: 'DOI Example' }]
                }
              ]
          end
        )
      end
    end
    let(:related_links) do
      [
        {
          'text' => 'DOI Example',
          'url' => 'https://doi.org/10.1234/5678'
        }
      ]
    end

    it 'returns the related links' do
      expect(described_class.call(cocina_object:)).to eq related_links
    end
  end

  context 'when object has no related links' do
    let(:cocina_object) { build(:collection, title: title_fixture) }

    it 'returns nil' do
      expect(described_class.call(cocina_object:)).to be_nil
    end
  end
end
