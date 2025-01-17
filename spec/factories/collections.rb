# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    user
    release_option { 'depositor_selects' }
    release_duration { 'one_year' }
    access { 'depositor_selects' }
    doi_option { 'yes' }
    custom_rights_statement_option { 'provided' }
    provided_custom_rights_statement { 'My custom rights statement' }
    license_option { 'depositor_selects' }
    license { 'https://www.apache.org/licenses/LICENSE-2.0' }
    review_enabled { false }

    trait :with_review_workflow do
      transient do
        reviewers_count { 1 }
      end

      review_enabled { true }
      reviewers { create_list(:user, reviewers_count) }
    end

    trait :with_managers do
      transient do
        managers_count { 1 }
      end

      managers { create_list(:user, managers_count) }
    end

    trait :with_depositors do
      transient do
        depositors_count { 1 }
      end

      depositors { create_list(:user, depositors_count) }
    end

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end
  end
end
