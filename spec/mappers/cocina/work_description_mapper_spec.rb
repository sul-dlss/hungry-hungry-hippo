# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::WorkDescriptionMapper, type: :mapping do
  subject(:description) { described_class.call(work_form:) }

  context 'when duplicate keywords' do
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.keywords_attributes = keywords_attributes
      end
    end

    let(:keywords_attributes) do
      [
        {
          'text' => 'Biology',
          'uri' => 'http://id.worldcat.org/fast/832383/',
          'cocina_type' => 'topic'
        },
        {
          'text' => 'MyBespokeKeyword',
          'uri' => nil,
          'cocina_type' => nil
        },
        {
          'text' => 'Biology',
          'uri' => 'http://id.worldcat.org/fast/832383/',
          'cocina_type' => 'topic'
        }
      ]
    end

    it 'maps to cocina' do
      expect(description.subject.size).to eq 2
      expect(description.subject[0].value).to eq 'Biology'
      expect(description.subject[1].value).to eq 'MyBespokeKeyword'
    end
  end

  context 'with a contributor containing only empty affiliations' do
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.contributors_attributes = contributors_attributes
      end
    end

    let(:contributors_attributes) do
      [
        {
          'affiliations_attributes' => [{ 'institution' => nil, 'uri' => nil, 'department' => nil }],
          'first_name' => 'Dana',
          'last_name' => 'Scully',
          'organization_name' => nil,
          'person_role' => 'author',
          'organization_role' => nil,
          'stanford_degree_granting_institution' => false,
          'suborganization_name' => nil,
          'role_type' => 'person',
          'with_orcid' => false,
          'orcid' => nil,
          'collection_required' => false
        }
      ]
    end

    it 'maps to cocina with the expected number of contributors' do
      expect(description.contributor.size).to eq(4)
    end
  end
end
