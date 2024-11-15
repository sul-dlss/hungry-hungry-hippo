# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    sequence(:title) { |n| "Work #{n}" }
    user
    collection

    trait :deposit_job_started do
      deposit_job_started_at { Time.zone.now }
    end
  end
end
