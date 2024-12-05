# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    user

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end
  end
end
