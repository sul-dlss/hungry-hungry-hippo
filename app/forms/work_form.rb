# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  attribute :title, :string
  validates :title, presence: true
end
