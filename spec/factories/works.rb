# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    sequence(:title) { |n| "Work #{n}" }
    user
    collection factory: %i[collection with_druid]
    object_updated_at { Time.zone.now }
    doi_assigned { true }

    trait :persisting do
      deposit_state { 'deposit_persisting' }
    end

    trait :with_druid do
      druid { generate(:unique_druid) }
    end
  end
end
