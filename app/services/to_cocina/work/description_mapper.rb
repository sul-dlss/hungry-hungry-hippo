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

      def params # rubocop:disable Metrics/AbcSize
        {
          title: Generators::Description.title(title: work_form.title),
          contributor: ContributorsMapper.call(contributor_forms: work_form.contributors_attributes),
          note: note_params,
          event: EventsMapper.call(work_form:),
          subject: Generators::Description.keywords(keywords: work_form.keywords_attributes),
          form: TypesMapper.call(work_form:),
          purl: Sdr::Purl.from_druid(druid: work_form.druid),
          relatedResource: related_resource_params,
          access: {
            accessContact: access_contact_params
          }
        }.compact
      end

      def note_params # rubocop:disable Metrics/AbcSize
        [].tap do |params|
          if work_form.abstract.present?
            params << Generators::Description.note(type: 'abstract',
                                                   value: work_form.abstract)
          end
          if work_form.citation.present? && work_form.auto_generate_citation == false
            params << Generators::Description.note(type: 'preferred citation',
                                                   value: work_form.citation,
                                                   label: 'Preferred Citation')
          end
        end.presence
      end

      def related_resource_params
        Generators::Description.related_works(related_works: work_form.related_works_attributes) +
          Generators::Description.related_links(related_links: work_form.related_links_attributes)
      end

      def access_contact_params
        Generators::Description.contact_emails(
          # Use `#dup` because mutating the passed-in form object would be unexpected
          contact_emails: work_form.contact_emails_attributes.dup.tap do |contact_emails_attributes|
            next if work_form.works_contact_email.blank?

            contact_emails_attributes << ContactEmailForm.new(email: work_form.works_contact_email)
          end
        )
      end
    end
  end
end
