# frozen_string_literal: true

FactoryBot.define do
  factory :affiliation, class: 'Affiliation' do
    institution { 'Stanford University' }
    uri { 'https://ror.org/01abcd' }
    department { 'Department of History' }
  end
end
