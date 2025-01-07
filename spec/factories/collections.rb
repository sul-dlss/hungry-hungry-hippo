# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    user
    release_option { 'depositor_selects' }
    release_duration { 'one_year' }
    access { 'depositor_selects' }
    doi_option { 'yes' }
    custom_rights_statement_option { 'with_custom_rights_statement' }
    provided_custom_rights_statement { 'My custom rights statement' }
    license_option { 'required' }
    license { 'CC0-1.0' }
    review_enabled { false }

    trait :with_review_workflow do
      review_enabled { true }
    end

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end
  end
end
