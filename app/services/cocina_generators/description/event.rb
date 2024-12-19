# frozen_string_literal: true

module CocinaGenerators
  class Description
    # Generates the Cocina parameters for an event
    class Event
      def self.call(...)
        new(...).call
      end

      # @param date [String,nil] the value of the date, e.g., '2024-03'
      # @param type [String] the type of the date, e.g., 'publication'
      # @param date_encoding_code [String] the encoding code for the date, e.g., 'edtf'
      # @param primary [Boolean] whether this is the primary date
      def initialize(type:, date: nil, date_encoding_code: 'edtf', primary: false)
        @type = type
        @date = date
        @date_encoding_code = date_encoding_code
        @primary = primary
      end

      def call
        {
          type:,
          date: dates
        }.compact
      end

      private

      attr_reader :type, :date, :date_encoding_code, :primary

      def dates
        return unless date

        [
          {
            value: date,
            type:,
            encoding: { code: date_encoding_code }
          }.tap do |date_params|
            date_params[:status] = 'primary' if primary
          end
        ]
      end
    end
  end
end
