# frozen_string_literal: true

FactoryBot.define do
  factory :share do
    work
    user
    permission { 'view' }
  end
end
