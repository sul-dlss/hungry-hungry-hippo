# frozen_string_literal: true

# Fixtures for mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module WorkMappingFixtures
  def new_work_form_fixture
    WorkForm.new(
      title: title_fixture,
      authors_attributes: authors_fixture,
      abstract: abstract_fixture,
      citation: citation_fixture,
      auto_generate_citation: false,
      related_links_attributes: related_links_fixture,
      related_works_attributes: related_works_fixture,
      license: license_fixture,
      collection_druid: collection_druid_fixture,
      publication_date_attributes: { year: '2024', month: '12' },
      contact_emails_attributes: contact_emails_fixture,
      keywords_attributes: keywords_fixture,
      work_type: work_type_fixture,
      work_subtypes: work_subtypes_fixture,
      access: 'stanford',
      release_option: 'delay',
      release_date: release_date_fixture,
      custom_rights_statement: custom_rights_statement_fixture,
      doi_option: 'yes'
    )
  end

  def work_form_fixture
    new_work_form_fixture.tap do |form|
      form.druid = druid_fixture
      form.version = 2
      form.lock = lock_fixture
      form.doi_option = 'assigned'
    end
  end

  # No external identifiers
  def new_content_fixture(user: nil)
    content = Content.create!(user: user || create(:user))
    ContentFile.create(
      file_type: 'attached',
      content:,
      filepath: filename_fixture,
      label: file_label_fixture,
      size: file_size_fixture,
      mime_type: mime_type_fixture,
      md5_digest: md5_fixture,
      sha1_digest: sha1_fixture
    )
    content
  end

  def content_fixture(user: nil, hide: false)
    content = Content.create!(user: user || create(:user))
    ContentFile.create(
      file_type: 'deposited',
      content:,
      filepath: filename_fixture,
      label: file_label_fixture,
      size: file_size_fixture,
      mime_type: mime_type_fixture,
      md5_digest: md5_fixture,
      sha1_digest: sha1_fixture,
      external_identifier: file_external_identifier_fixture,
      fileset_external_identifier: fileset_external_identifier_fixture,
      hide:
    )
    content
  end

  def request_dro_fixture # rubocop:disable Metrics/AbcSize
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          subject: CocinaDescriptionSupport.keywords(keywords: keywords_fixture),
          contributor: [CocinaGenerators::Description.person_contributor(**person_contributor_fixture),
                        CocinaGenerators::Description.organization_contributor(**organization_contributor_fixture)],
          event: [CocinaGenerators::Description.event(type: 'publication', date: '2024-12', primary: true)],
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture),
                 CocinaDescriptionSupport.note(type: 'preferred citation',
                                               value: citation_fixture,
                                               label: 'Preferred Citation')],
          relatedResource: CocinaDescriptionSupport.related_works(related_works: related_works_fixture) +
                           CocinaDescriptionSupport.related_links(related_links: related_links_fixture),
          access: { accessContact: CocinaDescriptionSupport.contact_emails(contact_emails: contact_emails_fixture) },
          form: form_fixture
        },
        version: 1,
        identification: { sourceId: source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo, partOfProject: Settings.project_tag },
        access: { view: 'citation-only', download: 'none', license: license_fixture,
                  useAndReproductionStatement: full_custom_rights_statement_fixture,
                  embargo: { view: 'stanford', download: 'stanford', releaseDate: release_date_fixture } },
        structural: { isMemberOf: [collection_druid_fixture] }
      }
    )
  end

  def form_fixture
    [
      {
        structuredValue: [
          {
            value: 'Image',
            type: 'type'
          },
          {
            value: 'CAD',
            type: 'subtype'
          },
          {
            value: 'Map',
            type: 'subtype'
          }
        ],
        type: 'resource type',
        source: {
          value: 'Stanford self-deposit resource types'
        }
      },
      {
        value: 'Computer-aided designs',
        type: 'genre',
        uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm002405',
        source: {
          code: 'lctgm'
        }
      },
      {
        value: 'Maps',
        type: 'genre',
        uri: 'http://id.loc.gov/authorities/genreForms/gf2011026387',
        source: {
          code: 'lcgft'
        }
      },
      {
        value: 'still image',
        type: 'resource type',
        source: {
          value: 'MODS resource types'
        }
      },
      {
        value: 'cartographic',
        type: 'resource type',
        source: {
          value: 'MODS resource types'
        }
      },
      {
        value: 'Image',
        type: 'resource type',
        source: {
          value: 'DataCite resource types'
        }
      }
    ]
  end

  def request_dro_with_structural_fixture
    request_dro_fixture.new(structural: {
                              contains: [{
                                type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                label: file_label_fixture,
                                version: 1,
                                structural: {
                                  contains: [
                                    {
                                      type: 'https://cocina.sul.stanford.edu/models/file',
                                      label: file_label_fixture,
                                      filename: filename_fixture,
                                      size: file_size_fixture,
                                      version: 1,
                                      hasMimeType: mime_type_fixture,
                                      sdrGeneratedText: false,
                                      correctedForAccessibility: false,
                                      hasMessageDigests: [
                                        {
                                          type: 'md5',
                                          digest: md5_fixture
                                        },
                                        {
                                          type: 'sha1',
                                          digest: sha1_fixture
                                        }
                                      ],
                                      access: {
                                        view: 'stanford',
                                        download: 'stanford',
                                        controlledDigitalLending: false
                                      },
                                      administrative: {
                                        publish: true,
                                        sdrPreserve: true,
                                        shelve: true
                                      }
                                    }
                                  ]
                                }
                              }],
                              isMemberOf: [collection_druid_fixture]
                            })
  end

  def dro_fixture # rubocop:disable Metrics/AbcSize
    Cocina::Models.build(
      {
        externalIdentifier: druid_fixture,
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          subject: CocinaDescriptionSupport.keywords(keywords: keywords_fixture),
          contributor: [CocinaGenerators::Description.person_contributor(**person_contributor_fixture),
                        CocinaGenerators::Description.organization_contributor(**organization_contributor_fixture)],
          event: [CocinaGenerators::Description.event(type: 'publication', date: '2024-12', primary: true)],
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture),
                 CocinaDescriptionSupport.note(type: 'preferred citation',
                                               value: citation_fixture,
                                               label: 'Preferred Citation')],
          relatedResource: CocinaDescriptionSupport.related_works(related_works: related_works_fixture) +
                           CocinaDescriptionSupport.related_links(related_links: related_links_fixture),
          access: { accessContact: CocinaDescriptionSupport.contact_emails(contact_emails: contact_emails_fixture) },
          form: form_fixture,
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 2,
        identification: { sourceId: source_id_fixture, doi: doi_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'citation-only',
                  download: 'none',
                  license: license_fixture,
                  useAndReproductionStatement: full_custom_rights_statement_fixture,
                  embargo: { view: 'stanford', download: 'stanford', releaseDate: release_date_fixture } },
        structural: { isMemberOf: [collection_druid_fixture] }
      }
    )
  end

  def dro_with_structural_fixture(hide: false)
    dro_fixture.new(structural: {
                      contains: [
                        {
                          type: 'https://cocina.sul.stanford.edu/models/resources/file',
                          externalIdentifier: fileset_external_identifier_fixture,
                          label: file_label_fixture,
                          version: 2,
                          structural: {
                            contains: [
                              {
                                type: 'https://cocina.sul.stanford.edu/models/file',
                                externalIdentifier: file_external_identifier_fixture,
                                label: file_label_fixture,
                                filename: filename_fixture,
                                size: file_size_fixture,
                                version: 2,
                                hasMimeType: mime_type_fixture,
                                sdrGeneratedText: false,
                                correctedForAccessibility: false,
                                hasMessageDigests: [
                                  {
                                    type: 'md5',
                                    digest: md5_fixture
                                  },
                                  {
                                    type: 'sha1',
                                    digest: sha1_fixture
                                  }
                                ],
                                access: {
                                  view: 'stanford',
                                  download: 'stanford',
                                  controlledDigitalLending: false
                                },
                                administrative: {
                                  publish: !hide,
                                  sdrPreserve: true,
                                  shelve: !hide
                                }
                              }
                            ]
                          }
                        }
                      ],
                      isMemberOf: [collection_druid_fixture]
                    })
  end

  def dro_with_metadata_fixture
    Cocina::Models.with_metadata(dro_fixture, lock_fixture)
  end

  def dro_with_structural_and_metadata_fixture(**)
    Cocina::Models.with_metadata(dro_with_structural_fixture(**), lock_fixture)
  end

  RSpec.configure do |config|
    config.include WorkMappingFixtures, type: :mapping
  end
end
