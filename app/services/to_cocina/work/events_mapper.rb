# frozen_string_literal: true

module ToCocina
  module Work
    # Maps WorkForm to Cocina event parameters
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
        [creation_date_event_params, publication_date_event_params].compact
      end

      private

      attr_reader :work_form

      delegate :publication_date, :create_date_type, :create_date_single, :create_date_range_from,
               :create_date_range_to, to: :work_form

      def creation_date_event_params
        date = if create_date_type == 'single'
                 create_date_single.to_s
               else
                 "#{create_date_range_from}/#{create_date_range_to}"
               end

        return if date.nil?

        CocinaGenerators::Description.event(type: 'creation',
                                            date:)
      end

      def publication_date_event_params
        date = publication_date.to_s
        return if date.nil?

        CocinaGenerators::Description.event(type: 'publication', primary: true,
                                            date:)
      end
    end
  end
end
