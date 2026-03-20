# frozen_string_literal: true

# Form object for handling date input
class DateForm < ApplicationForm
  attribute :year, :integer
  validates :year, numericality: {
    greater_than_or_equal_to: 1000,
    allow_nil: true,
    message: I18n.t('validations.date.year.greater_than_or_equal_to')
  }
  validates :year, numericality: { less_than_or_equal_to: Time.zone.now.year,
                                   allow_nil: true,
                                   message: I18n.t('validations.date.year.less_than_or_equal_to') }
  validates :year, presence: { message: I18n.t('validations.date.year.blank') }, if: -> { month.present? }
  attribute :month, :integer
  validates :month, numericality: {
    greater_than_or_equal_to: 1,
    allow_nil: true,
    message: I18n.t('validations.date.month.greater_than_or_equal_to')
  }
  validates :month, numericality: {
    less_than_or_equal_to: 12,
    allow_nil: true,
    message: I18n.t('validations.date.month.less_than_or_equal_to')
  }
  validates :month, presence: { message: I18n.t('validations.date.month.blank') }, if: -> { day.present? }
  attribute :day, :integer
  validates :day, numericality: {
    greater_than_or_equal_to: 1,
    allow_nil: true,
    message: I18n.t('validations.date.day.greater_than_or_equal_to')
  }
  validates :day, numericality: {
    less_than_or_equal_to: 31,
    allow_nil: true,
    message: I18n.t('validations.date.day.less_than_or_equal_to')
  }
  validate :valid_date, if: -> { day.present? }

  attribute :approximate, :boolean, default: false

  # if the user enters a year value that is not a number, set to nil instead of the default (which is cast to 0)
  # this re-renders year as blank instead of 0, see https://github.com/sul-dlss/hungry-hungry-hippo/issues/2231
  def year=(value)
    if value.is_a?(String) && value.match?(/\D/)
      super(nil)
    else
      super
    end
  end

  def to_s
    to_date&.to_fs(:edtf)
  rescue Date::Error
    'invalid date'
  end

  def to_date
    EdtfDate.for(year:, month:, day:, approximate:)
  end

  def valid_date
    to_date
  rescue Date::Error
    errors.add(:day, I18n.t('validations.date.day.invalid_date'))
  end
end
