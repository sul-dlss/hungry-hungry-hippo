# frozen_string_literal: true

# Generates the Cocina parameters for an event
class EventCocinaBuilder
  def self.call(...)
    new(...).call
  end

  # @param date [EDTF::*,String] the value of the date, e.g., '2024-03'
  # @param type [String] the type of the event, e.g., 'deposit'
  # @param date_type [String] the type of the date, e.g., 'publication' if different than the event type
  # @param date_encoding_code [String] the encoding code for the date, e.g., 'edtf'
  # @param primary [Boolean] whether this is the primary date
  def initialize(date:, type:, date_type: nil, date_encoding_code: 'edtf', primary: false)
    @type = type
    @etdf_date = date.is_a?(String) ? EDTF.parse(date) : date
    @date_encoding_code = date_encoding_code
    @primary = primary
    @date_type = date_type || type
  end

  def call
    {
      type:,
      date: dates_props
    }.compact
  end

  private

  attr_reader :type, :etdf_date, :date_encoding_code, :primary, :date_type

  def dates_props
    return unless etdf_date

    date_props = case etdf_date
                 when EDTF::Interval
                   interval_date_props
                 else
                   date_props_for(date: etdf_date)
                 end
    [
      {
        encoding: { code: date_encoding_code },
        type: date_type,
        status: primary ? 'primary' : nil
      }.merge(date_props).compact
    ]
  end

  def date_props_for(date:, type: nil, omit_qualifier: false)
    {
      value: date.edtf.chomp('~'),
      type:
    }.tap do |props|
      props[:qualifier] = 'approximate' if date.approximate? && !omit_qualifier
    end.compact
  end

  def interval_date_props
    approximate = etdf_date.from.approximate? && etdf_date.to.approximate?

    {
      structuredValue: [
        date_props_for(date: etdf_date.from, type: 'start', omit_qualifier: approximate),
        date_props_for(date: etdf_date.to, type: 'end', omit_qualifier: approximate)
      ]
    }.tap do |props|
      props[:qualifier] = 'approximate' if approximate
    end.compact
  end
end
