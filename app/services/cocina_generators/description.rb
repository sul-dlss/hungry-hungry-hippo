# frozen_string_literal: true

module CocinaGenerators
  # Generates Cocina Description
  class Description
    def self.person_contributor(...)
      PersonContributor.call(...)
    end

    def self.organization_contributor(...)
      OrganizationContributor.call(...)
    end

    def self.event(...)
      Event.call(...)
    end

    def self.note(...)
      Note.call(...)
    end

    def self.title(title:)
      [{ value: title }]
    end

    def self.contact_emails(contact_emails:)
      ContactEmails.call(contact_emails:)
    end

    def self.keywords(keywords:)
      Keywords.call(keywords:)
    end

    def self.related_links(related_links:)
      RelatedLinks.call(related_links:)
    end

    def self.related_works(related_works:)
      RelatedWorks.call(related_works:)
    end
  end
end
