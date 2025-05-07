# frozen_string_literal: true

FactoryBot.define do
  factory :content do
    user

    trait :with_content_files do
      transient do
        content_files_count { 2 }
      end

      content_files { create_list(:content_file, content_files_count) }
    end
  end
end
