# frozen_string_literal: true

# EDTF date value object
class EdtfDate
  def self.for(...)
    new(...).to_date
  end

  attr_reader :year, :month, :day, :approximate

  def initialize(year:, month: nil, day: nil, approximate: false)
    @year = year
    @month = month
    @day = day
    @approximate = approximate
  end

  def to_date
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
