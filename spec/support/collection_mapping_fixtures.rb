# frozen_string_literal: true

# Fixtures for collection mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module CollectionMappingFixtures
  def new_collection_form_fixture
    CollectionForm.new(
      title: collection_title_fixture,
      description: collection_description_fixture,
      contact_emails_attributes: contact_emails_fixture,
      related_links_attributes: related_links_fixture
    )
  end

  def collection_form_fixture
    new_collection_form_fixture.tap do |form|
      form.druid = collection_druid_fixture
      form.version = 2
      form.lock = lock_fixture
    end
  end

  def request_collection_fixture
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.collection,
        label: collection_title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: collection_title_fixture),
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: collection_description_fixture)],
          relatedResource: CocinaDescriptionSupport.related_links(related_links: related_links_fixture),
          access: { accessContact: CocinaDescriptionSupport.contact_emails(contact_emails: contact_emails_fixture) }
        },
        version: 1,
        identification: { sourceId: collection_source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo, partOfProject: Settings.project_tag },
        access: { view: 'world' }
      }
    )
  end

  def collection_fixture
    Cocina::Models.build(
      {
        externalIdentifier: collection_druid_fixture,
        type: Cocina::Models::ObjectType.collection,
        label: collection_title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: collection_title_fixture),
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: collection_description_fixture)],
          relatedResource: CocinaDescriptionSupport.related_links(related_links: related_links_fixture),
          access: { accessContact: CocinaDescriptionSupport.contact_emails(contact_emails: contact_emails_fixture) },
          purl: Sdr::Purl.from_druid(druid: collection_druid_fixture)
        },
        version: 2,
        identification: { sourceId: collection_source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world' }
      }
    )
  end

  def collection_with_metadata_fixture
    Cocina::Models.with_metadata(collection_fixture, lock_fixture)
  end

  RSpec.configure do |config|
    config.include CollectionMappingFixtures, type: :mapping
  end
end
