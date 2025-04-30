# frozen_string_literal: true

# Fixtures for collection mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module CollectionMappingFixtures
  def new_collection_form_fixture
    CollectionForm.new(
      title: collection_title_fixture,
      description: collection_description_fixture,
      release_option: 'depositor_selects',
      release_duration: 'one_year',
      access: 'depositor_selects',
      license_option: 'required',
      license: collection_license_fixture,
      doi_option: 'yes',
      custom_rights_statement_option: 'provided',
      provided_custom_rights_statement: 'My custom rights statement',
      custom_rights_statement_instructions: 'My custom rights statement instructions',
      contact_emails_attributes: contact_emails_fixture,
      related_links_attributes: related_links_fixture,
      managers_attributes: collection_manager_fixture,
      reviewers_attributes: collection_reviewer_fixture,
      depositors_attributes: collection_depositor_fixture,
      work_type: work_type_fixture,
      work_subtypes: work_subtypes_fixture,
      works_contact_email: works_contact_email_fixture,
      contributors_attributes: contributors_fixture
    )
  end

  def collection_form_fixture
    new_collection_form_fixture.tap do |form|
      form.druid = collection_druid_fixture
      form.version = 2
      form.lock = lock_fixture
      form.apo = 'druid:jv992ry2432'
    end
  end

  def request_collection_fixture
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.collection,
        label: collection_title_fixture,
        description: {
          title: DescriptionCocinaBuilder.title(title: collection_title_fixture),
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: collection_description_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_links(related_links: related_links_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(contact_emails: contact_emails_fixture)
          }
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
          title: DescriptionCocinaBuilder.title(title: collection_title_fixture),
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: collection_description_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_links(related_links: related_links_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(contact_emails: contact_emails_fixture)
          },
          purl: Sdr::Purl.from_druid(druid: collection_druid_fixture)
        },
        version: 2,
        identification: { sourceId: collection_source_id_fixture },
        administrative: { hasAdminPolicy: 'druid:jv992ry2432' },
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
