# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaSupport do
  include WorkMappingFixtures

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

  describe '#related_works_for' do
    context 'when object has related works' do
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
                  type: related_works_fixture.first['relationship'],
                  note: [
                    {
                      type: 'preferred citation',
                      value: related_works_fixture.first['citation']
                    }
                  ]
                },
                {
                  type: related_works_fixture.second['relationship'],
                  identifier: [
                    {
                      uri: related_works_fixture.second['identifier']
                    }
                  ]
                }
              ]
            end
          )
        end
      end

      it 'returns the related works' do
        expect(described_class.related_works_for(cocina_object:)).to eq related_works_fixture
      end
    end

    context 'when object has no related works' do
      let(:cocina_object) { build(:dro, title: title_fixture) }

      it 'returns nil' do
        expect(described_class.related_works_for(cocina_object:)).to be_nil
      end
    end
  end

  describe '#abstract_for' do
    let(:cocina_object) do
      # NOTE: the :dro factory in the cocina-models gem does not have a seam
      #       for injecting abstract, so we do it manually here
      build(:dro, title: title_fixture).then do |object|
        object.new(
          object
          .to_h
          .tap do |obj|
            obj[:description][:note] =
              [
                {
                  type: 'abstract',
                  value: abstract_fixture
                }
              ]
          end
        )
      end
    end

    it 'returns the abstract' do
      expect(described_class.abstract_for(cocina_object:)).to eq abstract_fixture
    end
  end

  describe '#update_version_and_lock' do
    subject(:updated_cocina_object) do
      described_class.update_version_and_lock(cocina_object: cocina_object, version: version, lock: lock)
    end

    let(:cocina_object) do
      dro_with_structural_and_metadata_fixture
    end

    let(:version) { 3 }
    let(:lock) { 'bcd234' }

    it 'updates the version and lock' do
      expect(updated_cocina_object.lock).to eq lock
      expect(updated_cocina_object.version).to eq version
      expect(updated_cocina_object.structural.contains.first.version).to eq version
      expect(updated_cocina_object.structural.contains.first.structural.contains.first.version).to eq version
    end
  end
end
