# frozen_string_literal: true

module ToCocina
  module Work
    # Maps AuthorForms to Cocina contributor parameters
    class EventsMapper
      PUBLISHER_ROLE = 'publisher'

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
        return unless publication_date.year.present? || publisher_contributors.present?

        CocinaGenerators::Description.event(type: 'publication', primary: true,
                                            date: publication_date&.to_s).tap do |event_params|
          # Publishers get added as contributors to the publication event
          event_params[:contributor] = publication_data_contributor_params if publisher_contributors.present?
        end
      end

      def publication_data_contributor_params
        publisher_contributors.map do |contributor|
          CocinaGenerators::Description::OrganizationContributor.call(name: contributor.organization_name,
                                                                      role: PUBLISHER_ROLE)
        end
      end

      def publisher_contributors
        @publisher_contributors ||= work_form.authors_attributes.select do |contributor|
          contributor.organization_role == PUBLISHER_ROLE
        end
      end
    end
  end
end
