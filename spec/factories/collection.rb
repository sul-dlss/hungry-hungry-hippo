# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    druid { generate(:unique_druid) }
    user
  end
end
