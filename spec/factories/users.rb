# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "A#{n}. User" }
    sequence(:first_name) { |n| "A#{n}. User" }
    sequence(:email_address) { |n| "a#{n}.user@stanford.edu" }
    agreed_to_terms_at { Time.zone.now }

    trait :connected_to_github do
      github_access_token { 'fake-github-access-token' }
      sequence(:github_uid) { |n| "12345678#{n}" }
      sequence(:github_nickname) { |n| "githubuser#{n}" }
      github_connected_at { Time.zone.now }
      github_updated_at { Time.zone.now }
    end
  end
end
