# frozen_string_literal: true

# Helpers for working with EDTF dates
class EdtfSupport
  # Convert a year, month, and day to an EDTF date string
  def self.to_edtf_s(year:, month: nil, day: nil, approximate: false)
    to_edtf(year:, month:, day:, approximate:)&.edtf
  end

  # Convert a year, month, and day to an EDTF date
  def self.to_edtf(year:, month: nil, day: nil, approximate: false)
    return if year.blank?

    date = Date.new(*[year, month, day].compact)
    if month.nil?
      date.year_precision!
    elsif day.nil?
      date.month_precision!
    end
    date.approximate! if approximate
    date
  end
end
