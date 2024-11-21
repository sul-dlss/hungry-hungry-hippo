# frozen_string_literal: true

FactoryBot.define do
  factory :content_file do
    sequence(:filename) { |n| "file#{n}.txt" }
    sequence(:label) { |n| "My file #{n}" }
    content
    file_type { 'deposited' }
  end
end
