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
    custom_rights_statement_instructions { 'My custom rights statement instructions' }
    license_option { 'required' }
    license { 'https://creativecommons.org/licenses/by/4.0/legalcode' }
    review_enabled { false }
    article_deposit_enabled { false }
    github_deposit_enabled { false }
    email_when_participants_changed { false }
    email_depositors_status_changed { false }

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

    trait :with_works do
      transient do
        works_count { 3 }
      end

      works { create_list(:work, works_count - 1, :with_druid) + create_list(:work, 1) }
    end

    trait :registering_or_updating do
      deposit_state { 'deposit_registering_or_updating' }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end

    trait :with_required_types do
      work_type { 'Image' }
      work_subtypes { %w[Data Photograph] }
    end

    trait :with_required_contact_email do
      works_contact_email { 'collection.manager@stanford.example.edu' }
    end
  end
end
