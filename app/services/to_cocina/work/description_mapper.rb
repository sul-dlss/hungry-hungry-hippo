# frozen_string_literal: true

module ToCocina
  module Work
    # Maps a WorkForm to a Cocina description
    class DescriptionMapper
      def self.call(...)
        new(...).call
      end

      # @param [WorkForm] work_form
      def initialize(work_form:)
        @work_form = work_form
      end

      # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
      def call
        if work_form.persisted?
          Cocina::Models::Description.new(params)
        else
          Cocina::Models::RequestDescription.new(params)
        end
      end

      private

      attr_reader :work_form

      def params
        {
          title: CocinaDescriptionSupport.title(title: work_form.title),
          # contributor: contributors_params.presence,
          note: note_params,
          event: event_params,
          # subject: subject_params.presence,
          purl: Sdr::Purl.from_druid(druid: work_form.druid),
          relatedResource: CocinaDescriptionSupport.related_works(related_works: work_form.related_works_attributes) +
            CocinaDescriptionSupport.related_links(related_links: work_form.related_links_attributes)
        }.compact
      end

      # def contributors_params
      #   work_form.authors.map do |contributor|
      #     CocinaDescriptionSupport.person_contributor(
      #       forename: contributor.first_name,
      #       surname: contributor.last_name
      #     )
      #   end
      # end

      def note_params
        [].tap do |params|
          if work_form.abstract.present?
            params << CocinaDescriptionSupport.note(type: 'abstract',
                                                    value: work_form.abstract)
          end
        end.presence
      end

      def event_params
        [].tap do |params|
          if work_form.publication_date.year.present?
            params << CocinaDescriptionSupport.event_date(type: 'publication', primary: true,
                                                          date: work_form.publication_date.to_s)
          end
        end.presence
      end
    end
  end
end
