# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    user
  end
end
