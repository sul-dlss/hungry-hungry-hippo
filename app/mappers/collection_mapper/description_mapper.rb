# frozen_string_literal: true

class CollectionMapper
  # Maps a CollectionForm to a Cocina description
  class DescriptionMapper
    def self.call(...)
      new(...).call
    end

    # @param [CollectionForm] collection_form
    def initialize(collection_form:)
      @collection_form = collection_form
    end

    # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
    def call
      if collection_form.persisted?
        Cocina::Models::Description.new(params)
      else
        Cocina::Models::RequestDescription.new(params)
      end
    end

    private

    attr_reader :collection_form

    def params
      {
        title: Generators::Description.title(title: collection_form.title),
        note: note_params,
        purl: Sdr::Purl.from_druid(druid: collection_form.druid),
        relatedResource: Generators::Description.related_links(
          related_links: collection_form.related_links_attributes
        ),
        access: {
          accessContact: Generators::Description.contact_emails(
            contact_emails: collection_form.contact_emails_attributes
          )
        }
      }.compact
    end

    def note_params
      [].tap do |params|
        if collection_form.description.present?
          params << Generators::Description.note(type: 'abstract',
                                                 value: collection_form.description)
        end
      end.presence
    end
  end
end
