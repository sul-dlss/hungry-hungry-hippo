# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::ContributorMapper do
  context 'when a person' do
    let(:contributor) { create(:person_contributor) }

    it 'maps to attributes' do
      expect(described_class.call(contributor:)).to eq(
        first_name: contributor.first_name,
        last_name: 'Contributor',
        role_type: 'person',
        person_role: 'author',
        orcid: '0001-0002-0003-0004',
        with_orcid: true,
        stanford_degree_granting_institution: false
      )
    end
  end

  context 'when an organization' do
    let(:contributor) { create(:organization_contributor) }

    it 'maps to attributes' do
      expect(described_class.call(contributor:)).to eq(
        organization_name: contributor.organization_name,
        role_type: 'organization',
        organization_role: 'funder',
        suborganization_name: nil,
        stanford_degree_granting_institution: false,
        with_orcid: false
      )
    end
  end

  context 'when Stanford' do
    let(:contributor) { create(:organization_contributor, :stanford) }

    it 'maps to attributes' do
      expect(described_class.call(contributor:)).to eq(
        organization_name: 'Stanford University',
        role_type: 'organization',
        organization_role: 'degree_granting_institution',
        suborganization_name: 'Department of Philosophy',
        stanford_degree_granting_institution: true,
        with_orcid: false
      )
    end
  end
end
