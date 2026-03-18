# frozen_string_literal: true

# Form object for reviewing a work.
class ReviewForm < ApplicationForm
  attribute :review_option, :string, default: 'approve'
  validates :review_option,
            inclusion: { in: %w[approve reject],
                         message: I18n.t('review_form.fields.review_option.validations.inclusion') }

  attribute :reject_reason, :string
  validates :reject_reason,
            presence: { message: I18n.t('review_form.fields.reject_reason.validations.blank') },
            if: -> { review_option == 'reject' }
end
