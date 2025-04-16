# frozen_string_literal: true

# Generates Cocina Description
class DescriptionCocinaBuilder
  def self.person_contributor(...)
    PersonContributorCocinaBuilder.call(...)
  end

  def self.organization_contributor(...)
    OrganizationContributorCocinaBuilder.call(...)
  end

  def self.event(...)
    EventCocinaBuilder.call(...)
  end

  def self.note(...)
    NoteCocinaBuilder.call(...)
  end

  def self.title(title:)
    [{ value: title }]
  end

  def self.contact_emails(contact_emails:)
    ContactEmailsCocinaBuilder.call(contact_emails:)
  end

  def self.keywords(keywords:)
    KeywordsCocinaBuilder.call(keywords:)
  end

  def self.related_links(related_links:)
    RelatedLinksCocinaBuilder.call(related_links:)
  end

  def self.related_works(related_works:)
    RelatedWorksCocinaBuilder.call(related_works:)
  end

  def self.admin_metadata(creation_date:)
    AdminMetadataBuilder.call(creation_date:)
  end
end
