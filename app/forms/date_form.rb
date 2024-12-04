# frozen_string_literal: true

# Form object for handling date input
class DateForm < ApplicationForm
  attribute :year, :integer
  validates :year,
            numericality: { greater_than_or_equal_to: 1000, less_than_or_equal_to: Time.zone.now.year, allow_nil: true }
  validates :year, presence: true, if: -> { month.present? }
  attribute :month, :integer
  validates :month, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12, allow_nil: true }
  validates :month, presence: true, if: -> { day.present? }
  attribute :day, :integer
  validates :day, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31, allow_nil: true }

  def to_edtf_s
    EdtfSupport.to_edtf_s(year:, month:, day:)
  end
end
