# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelatedWorksMapper do
  context 'when object has related works' do
    let(:cocina_object) do
      build(:dro, title: title_fixture).then do |object|
        object.new(object.to_h.tap do |obj|
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
        end)
      end
    end

    it 'returns the related works' do
      expect(described_class.call(cocina_object:)).to eq related_works_fixture
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
end
