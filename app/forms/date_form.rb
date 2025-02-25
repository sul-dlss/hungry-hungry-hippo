# frozen_string_literal: true

# Form object for handling date input
class DateForm < ApplicationForm
  attribute :year, :integer
  validates :year, numericality: { greater_than_or_equal_to: 1000, allow_nil: true }
  validates :year, numericality: { less_than_or_equal_to: Time.zone.now.year,
                                   allow_nil: true,
                                   message: I18n.t('date.validation.year.less_than_or_equal_to') }
  validates :year, presence: true, if: -> { month.present? }
  attribute :month, :integer
  validates :month, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12, allow_nil: true }
  validates :month, presence: true, if: -> { day.present? }
  attribute :day, :integer
  validates :day, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31, allow_nil: true }
  attribute :approximate, :boolean, default: false

  def to_s
    to_date&.to_fs(:edtf)
  end

  def to_date
    EdtfDate.for(year:, month:, day:, approximate:)
  end
end
