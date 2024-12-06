# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    sequence(:title) { |n| "Work #{n}" }
    user
    collection factory: %i[collection with_druid]
    object_updated_at { Time.zone.now }

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end
  end
end
