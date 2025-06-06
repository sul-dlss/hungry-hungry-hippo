# frozen_string_literal: true

FactoryBot.define do
  factory :content_file do
    sequence(:filepath) { |n| "file#{n}.txt" }
    sequence(:label) { |n| "My file #{n}" }
    content
    file_type { 'deposited' }
    hide { false }

    trait :attached do
      file_type { 'attached' }

      after(:build) do |content_file|
        content_file.file.attach(
          io: Rails.root.join('spec/fixtures/files/hippo.png').open,
          filename: 'hippo.png',
          content_type: 'image/png'
        )
      end
    end

    trait :globus do
      file_type { 'globus' }
    end

    trait :deposited do
      file_type { 'deposited' }
    end
  end
end
