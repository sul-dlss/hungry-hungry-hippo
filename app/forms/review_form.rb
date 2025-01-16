# frozen_string_literal: true

# Form object for reviewing a work.
class ReviewForm < ApplicationForm
  attribute :review_option, :string, default: 'approve'
  validates :review_option, inclusion: { in: %w[approve reject] }

  attribute :reject_reason, :string
  validates :reject_reason, presence: true, if: -> { review_option == 'reject' }
end
