# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| "Collection #{n}" }
    druid { 'druid:cc234dd5678' }
    user
  end
end
