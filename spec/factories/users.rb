# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "A#{n}. User" }
    sequence(:first_name) { |n| "A#{n}. User" }
    sequence(:email_address) { |n| "a#{n}.user@stanford.edu" }
  end
end
