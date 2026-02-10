# frozen_string_literal: true

FactoryBot.define do
  factory :github_release do
    github_repository
    release_id { 1 }
    release_tag { 'v1.0' }
    release_name { 'First release' }
    zip_url { 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.0' }
    published_at { 2.days.ago }
  end
end
