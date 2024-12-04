# frozen_string_literal: true

# Helpers for working with EDTF dates
class EdtfSupport
  # Convert a year, month, and day to an EDTF date string
  def self.to_edtf_s(year:, month: nil, day: nil)
    return if year.blank?

    date = Date.new(*[year, month, day].compact)
    if month.nil?
      date.year_precision!
    elsif day.nil?
      date.month_precision!
    end
    date.edtf
  end
end
