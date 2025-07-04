# frozen_string_literal: true

# Fixtures for mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module WorkMappingFixtures
  def new_work_form_fixture # rubocop:disable Metrics/AbcSize
    WorkForm.new(
      title: title_fixture,
      contributors_attributes: contributors_fixture,
      abstract: abstract_fixture,
      citation: citation_fixture,
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
      doi_option: 'yes',
      agree_to_terms: false,
      create_date_range_from_attributes: creation_date_range_from_fixture,
      create_date_range_to_attributes: creation_date_range_to_fixture,
      create_date_type: 'range',
      whats_changing: 'Initial version',
      works_contact_email: works_contact_email_fixture,
      creation_date: creation_date_fixture
    )
  end

  def work_form_fixture # rubocop:disable Metrics/AbcSize
    new_work_form_fixture.tap do |form|
      form.druid = druid_fixture
      form.version = 2
      form.lock = lock_fixture
      form.doi_option = 'assigned'
      form.agree_to_terms = true
      form.whats_changing = whats_changing_fixture
      form.apo = 'druid:jv992ry2432'
      form.copyright = copyright_fixture
      form.deposit_publication_date = deposit_publication_date_fixture
    end
  end

  # No external identifiers
  def new_content_fixture(user: nil, hide: false)
    content = Content.create!(user: user || create(:user))
    ContentFile.create(
      file_type: 'attached',
      content:,
      filepath: filename_fixture,
      label: file_label_fixture,
      size: file_size_fixture,
      mime_type: mime_type_fixture,
      md5_digest: md5_fixture,
      sha1_digest: sha1_fixture,
      hide:
    )
    content
  end

  def new_pdf_content_fixture(user: nil, hide: false)
    content = Content.create!(user: user || create(:user))
    ContentFile.create(
      file_type: 'attached',
      content:,
      filepath: 'my_file.pdf',
      label: file_label_fixture,
      size: file_size_fixture,
      mime_type: 'application/pdf',
      md5_digest: md5_fixture,
      sha1_digest: sha1_fixture,
      hide:
    )
    content
  end

  def new_pdf_content_with_hierarchy_fixture(user: nil, hide: false)
    content = new_pdf_content_fixture(user:, hide:)
    ContentFile.create(
      file_type: 'attached',
      content:,
      filepath: 'my_sub_dir/my_second_file.pdf',
      label: 'My sub file',
      size: file_size_fixture,
      mime_type: 'application/pdf',
      md5_digest: md5_fixture,
      sha1_digest: sha1_fixture,
      hide:
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
          title: DescriptionCocinaBuilder.title(title: title_fixture),
          subject: DescriptionCocinaBuilder.keywords(keywords: keywords_fixture),
          contributor: [DescriptionCocinaBuilder.person_contributor(**person_contributor_fixture),
                        DescriptionCocinaBuilder.organization_contributor(**organization_contributor_fixture),
                        DescriptionCocinaBuilder.organization_contributor(**degree_granting_contributor_fixture)],
          event: [
            DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-07/2022-04~'),
            DescriptionCocinaBuilder.event(type: 'publication', date: '2024-12', primary: true)
          ],
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: abstract_fixture),
                 DescriptionCocinaBuilder.note(type: 'preferred citation', value: citation_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_works(related_works: related_works_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(
              contact_emails: contact_emails_fixture.append(ContactEmailForm.new(email: works_contact_email_fixture))
            )
          },
          form: form_fixture,
          adminMetadata: DescriptionCocinaBuilder.admin_metadata(creation_date: creation_date_fixture)
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
            value: 'Data',
            type: 'subtype'
          },
          {
            value: 'Photograph',
            type: 'subtype'
          }
        ],
        type: 'resource type',
        source: {
          value: 'Stanford self-deposit resource types'
        }
      },
      {
        value: 'Data sets',
        type: 'genre',
        uri: 'http://id.loc.gov/authorities/genreForms/gf2018026119',
        source: {
          code: 'lcgft'
        }
      },
      {
        value: 'dataset',
        type: 'genre',
        source: {
          code: 'local'
        }
      },
      {
        value: 'Photographs',
        type: 'genre',
        uri: 'http://id.loc.gov/authorities/genreForms/gf2017027249',
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
        value: 'Dataset',
        type: 'resource type',
        uri: 'http://id.loc.gov/vocabulary/resourceTypes/dat',
        source: {
          uri: 'http://id.loc.gov/vocabulary/resourceTypes/'
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
                                        view: 'dark',
                                        download: 'none',
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
          title: DescriptionCocinaBuilder.title(title: title_fixture),
          subject: DescriptionCocinaBuilder.keywords(keywords: keywords_fixture),
          contributor: [DescriptionCocinaBuilder.person_contributor(**person_contributor_fixture),
                        DescriptionCocinaBuilder.organization_contributor(**organization_contributor_fixture),
                        DescriptionCocinaBuilder.organization_contributor(**degree_granting_contributor_fixture)],
          event: [
            DescriptionCocinaBuilder.event(type: 'deposit', date_type: 'publication',
                                           date: deposit_publication_date_fixture),
            DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-07/2022-04~'),
            DescriptionCocinaBuilder.event(type: 'publication', date: '2024-12', primary: true)
          ],
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: abstract_fixture),
                 DescriptionCocinaBuilder.note(type: 'preferred citation', value: citation_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_works(related_works: related_works_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(
              contact_emails: contact_emails_fixture.append(ContactEmailForm.new(email: works_contact_email_fixture))
            )
          },
          form: form_fixture,
          adminMetadata: DescriptionCocinaBuilder.admin_metadata(creation_date: creation_date_fixture),
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 2,
        identification: { sourceId: source_id_fixture, doi: doi_fixture },
        administrative: { hasAdminPolicy: 'druid:jv992ry2432' },
        access: { view: 'citation-only',
                  download: 'none',
                  license: license_fixture,
                  useAndReproductionStatement: full_custom_rights_statement_fixture,
                  copyright: copyright_fixture,
                  embargo: { view: 'stanford', download: 'stanford', releaseDate: release_date_fixture } },
        structural: { isMemberOf: [collection_druid_fixture] }
      }
    )
  end

  def dro_with_structural_fixture(hide: false, version: 2)
    dro_fixture.new(structural: {
                      contains: [
                        {
                          type: 'https://cocina.sul.stanford.edu/models/resources/file',
                          externalIdentifier: fileset_external_identifier_fixture,
                          label: file_label_fixture,
                          version:,
                          structural: {
                            contains: [
                              {
                                type: 'https://cocina.sul.stanford.edu/models/file',
                                externalIdentifier: file_external_identifier_fixture,
                                label: file_label_fixture,
                                filename: filename_fixture,
                                size: file_size_fixture,
                                version:,
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
                                  view: 'dark',
                                  download: 'none',
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
