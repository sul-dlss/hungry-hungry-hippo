# frozen_string_literal: true

FactoryBot.define do
  factory :person_contributor, class: 'Contributor' do
    sequence(:first_name) { |n| "A#{n}." }
    last_name { 'Contributor' }
    collection
    role { 'author' }
    role_type { 'person' }
    orcid { '0001-0002-0003-0004' }

    trait :with_affiliation do
      after(:create) do |contributor|
        create(:affiliation, :with_department, contributor:)
      end
    end
  end

  factory :organization_contributor, class: 'Contributor' do
    sequence(:organization_name) { |n| "Organization#{n}" }
    collection
    role { 'funder' }
    role_type { 'organization' }

    trait :stanford do
      organization_name { 'Stanford University' }
      suborganization_name { 'Department of Philosophy' }
      role { 'degree_granting_institution' }
    end
  end
end
