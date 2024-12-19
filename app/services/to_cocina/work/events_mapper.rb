# frozen_string_literal: true

module ToCocina
  module Work
    # Maps AuthorForms to Cocina contributor parameters
    class EventsMapper
      def self.call(...)
        new(...).call
      end

      # @param [WorkForm] work_form
      def initialize(work_form:)
        @work_form = work_form
      end

      # @return [Array] the Cocina event parameters
      def call
        [publication_date_event_params].compact
      end

      private

      attr_reader :work_form

      delegate :publication_date, to: :work_form

      def publication_date_event_params
        return if publication_date.year.nil?

        CocinaGenerators::Description.event(type: 'publication', primary: true,
                                            date: publication_date&.to_s)
      end
    end
  end
end
