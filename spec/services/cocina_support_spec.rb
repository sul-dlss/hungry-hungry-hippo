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
    let(:cocina_object) do
      dro_with_metadata_fixture.new(structural: {
                                      contains: [
                                        {
                                          type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                          externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                          label: 'My file',
                                          version: 1,
                                          structural: {
                                            contains: [
                                              {
                                                type: 'https://cocina.sul.stanford.edu/models/file',
                                                externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file1.text',
                                                label: 'My file1',
                                                filename: 'my_file1.txt',
                                                size: 204_615,
                                                version: 1,
                                                hasMimeType: 'text/plain',
                                                sdrGeneratedText: false,
                                                correctedForAccessibility: false,
                                                hasMessageDigests: [
                                                  { type: 'md5', digest: '46b763ec34319caa5c1ed090aca46ef2' },
                                                  { type: 'sha1', digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea' }
                                                ],
                                                access: { view: 'world', download: 'world',
                                                          controlledDigitalLending: false },
                                                administrative: { publish: false, sdrPreserve: true, shelve: false }
                                              }
                                            ]
                                          }
                                        }
                                      ]
                                    })
    end

    let(:version) { 2 }
    let(:lock) { 'abc123' }
    let(:expected_cocina_object) do
      dro_with_metadata_fixture.new(structural: {
                                      contains: [
                                        {
                                          type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                          externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                          label: 'My file',
                                          version: 2,
                                          structural: {
                                            contains: [
                                              {
                                                type: 'https://cocina.sul.stanford.edu/models/file',
                                                externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file1.text',
                                                label: 'My file1',
                                                filename: 'my_file1.txt',
                                                size: 204_615,
                                                version: 2,
                                                hasMimeType: 'text/plain',
                                                sdrGeneratedText: false,
                                                correctedForAccessibility: false,
                                                hasMessageDigests: [
                                                  { type: 'md5', digest: '46b763ec34319caa5c1ed090aca46ef2' },
                                                  { type: 'sha1', digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea' }
                                                ],
                                                access: { view: 'world', download: 'world',
                                                          controlledDigitalLending: false },
                                                administrative: { publish: false, sdrPreserve: true, shelve: false }
                                              }
                                            ]
                                          }
                                        }
                                      ]
                                    })
    end

    it 'updates the version and lock' do
      expect(described_class.update_version_and_lock(cocina_object:, version:, lock:)).to eq(expected_cocina_object)
    end
  end
end
