# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    druid { generate(:unique_druid) }
    user

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end
  end
end
