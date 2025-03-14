# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::ContributorsMapper do
  subject(:contributor_params) { described_class.call(cocina_object:) }

  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(contributor: [cocina_contributor_params]))
  end

  context 'when role is absent' do
    let(:cocina_contributor_params) do
      {
        name: [
          {
            value: 'NASA'
          }
        ],
        type: 'organization',
        status: 'primary'
      }
    end

    it 'maps to contributor params' do
      expect(contributor_params).to eq([
                                         'first_name' => nil,
                                         'last_name' => nil,
                                         'role_type' => 'organization',
                                         'person_role' => nil,
                                         'organization_role' => nil,
                                         'organization_name' => 'NASA',
                                         'suborganization_name' => nil,
                                         'stanford_degree_granting_institution' => false,
                                         'orcid' => nil,
                                         'with_orcid' => false,
                                         'cited' => true
                                       ])
    end
  end
end
