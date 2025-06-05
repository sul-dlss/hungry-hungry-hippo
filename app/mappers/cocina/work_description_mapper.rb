# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Cocina
  # Maps a WorkForm to a Cocina description
  class WorkDescriptionMapper
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
        title: DescriptionCocinaBuilder.title(title: work_form.title),
        contributor: WorkContributorsMapper.call(contributor_forms: work_form.contributors_attributes),
        note: note_params,
        event: WorkEventsMapper.call(work_form:),
        subject: subject_params,
        form: WorkTypesMapper.call(work_form:),
        purl: Sdr::Purl.from_druid(druid: work_form.druid),
        relatedResource: related_resource_params,
        access: {
          accessContact: access_contact_params
        }.compact_blank.presence,
        adminMetadata: DescriptionCocinaBuilder.admin_metadata(creation_date: work_form.creation_date)
      }.compact
    end

    def note_params
      [].tap do |params|
        if work_form.abstract.present?
          params << DescriptionCocinaBuilder.note(type: 'abstract',
                                                  value: work_form.abstract)
        end
        if work_form.citation.present?
          params << DescriptionCocinaBuilder.note(type: 'preferred citation', value: work_form.citation)
        end
      end.presence
    end

    def related_resource_params
      DescriptionCocinaBuilder.related_links(related_links: work_form.related_links_attributes) +
        DescriptionCocinaBuilder.related_works(related_works: work_form.related_works_attributes)
    end

    def access_contact_params
      DescriptionCocinaBuilder.contact_emails(
        # Use `#dup` because mutating the passed-in form object would be unexpected
        contact_emails: work_form.contact_emails_attributes.dup.tap do |contact_emails_attributes|
          next if work_form.works_contact_email.blank?

          contact_emails_attributes << ContactEmailForm.new(email: work_form.works_contact_email)
        end
      )
    end

    def subject_params
      # Note that deduping only on text.
      keyword_forms = work_form.keywords_attributes.uniq(&:text)
      DescriptionCocinaBuilder.keywords(keywords: keyword_forms)
    end
  end
end
