# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaSupport do
  describe '#title_for' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns the title' do
      expect(described_class.title_for(cocina_object:)).to eq title_fixture
    end
  end

  describe '#related_links_for' do
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
                }
              ]
            end
          )
        end
      end

      it 'returns the related links' do
        expect(described_class.related_links_for(cocina_object:)).to eq related_links_fixture
      end
    end

    context 'when object has no related links' do
      let(:cocina_object) { build(:dro, title: title_fixture) }

      it 'returns nil' do
        expect(described_class.related_links_for(cocina_object:)).to be_nil
      end
    end
  end
end
