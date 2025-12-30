# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelatedWorksMapper do
  context 'when object has related works' do
    let(:cocina_object) do
      # NOTE: the :dro factory in the cocina-models gem does not have a seam
      #       for injecting related links, so we do it manually here
      build(:dro, title: title_fixture).then do |object|
        object.new(object.to_h.tap do |obj|
          obj[:description][:relatedResource] = [
            {
              type: 'part of',
              note: [
                {
                  type: 'preferred citation',
                  value: related_works_fixture.first['citation']
                }
              ],
              dataCiteRelationType: 'IsPartOf'
            },
            {
              type: 'has part',
              identifier: [
                {
                  uri: related_works_fixture.second['identifier']
                }
              ],
              dataCiteRelationType: 'HasPart'
            }
          ]
        end)
      end
    end

    it 'returns the related works' do
      expect(described_class.call(cocina_object:)).to eq related_works_fixture
    end
  end

  context 'when object has identifiers that are links' do
    let(:cocina_object) do
      build(:dro, title: title_fixture).then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
              obj[:description][:relatedResource] = [
                {
                  type: 'supplemented by',
                  dataCiteRelationType: 'IsSupplementedBy',
                  purl: related_works_links_fixture.first['identifier']
                },
                {
                  type: 'has version',
                  dataCiteRelationType: 'IsVersionOf',
                  identifier: [{
                    uri: related_works_links_fixture.second['identifier'],
                    type: 'doi'
                  }]
                },
                {
                  type: 'referenced by',
                  dataCiteRelationType: 'IsReferencedBy',
                  access: { url: [{ value: related_works_links_fixture.third['identifier'] }] }
                }
              ]
          end
        )
      end
    end

    it 'returns the related links' do
      expect(described_class.call(cocina_object:)).to eq related_works_links_fixture
    end
  end

  context 'when object has no related works' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns nil' do
      expect(described_class.call(cocina_object:)).to be_nil
    end
  end

  context 'when the object has related work without a relationship' do
    # H2 related resources don't have relationships
    let(:cocina_object) do
      build(:dro, title: title_fixture).then do |object|
        object.new(object.to_h.tap do |obj|
          obj[:description][:relatedResource] = [
            {
              note: [
                {
                  type: 'preferred citation',
                  value: 'my citation'
                }
              ]
            }
          ]
        end)
      end
    end

    it 'returns the related works' do
      expect(described_class.call(cocina_object:)).to eq [
        { 'relationship' => nil, 'identifier' => nil, 'citation' => 'my citation', 'use_citation' => true }
      ]
    end
  end

  context 'when the object has relationship type but no dataCiteRelationType' do
    let(:cocina_object) do
      build(:dro, title: title_fixture).then do |object|
        object.new(object.to_h.tap do |obj|
          obj[:description][:relatedResource] = [
            {
              type: 'part of',
              note: [
                {
                  type: 'preferred citation',
                  value: related_works_fixture.first['citation']
                }
              ]
            }
          ]
        end)
      end
    end

    it 'returns a related work with no relationship' do
      expect(described_class.call(cocina_object:)).to eq [
        { 'relationship' => nil, 'identifier' => nil, 'citation' => 'Here is a valid citation.',
          'use_citation' => true }
      ]
    end
  end

  context 'when the object has cocina type that is not a supported relationship' do
    let(:cocina_object) do
      build(:dro, title: title_fixture).then do |object|
        object.new(object.to_h.tap do |obj|
          obj[:description][:relatedResource] = [
            {
              type: 'reviewed by',
              note: [
                {
                  type: 'preferred citation',
                  value: related_works_fixture.first['citation']
                }
              ]
            }
          ]
        end)
      end
    end

    it 'returns nil' do
      expect(described_class.call(cocina_object:)).to be_nil
    end
  end
end
