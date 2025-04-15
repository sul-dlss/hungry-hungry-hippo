require 'rails_helper'

RSpec.describe LegacyDroNormalizer do
  let(:normalized_cocina_object) { described_class.call(cocina_object:, document: true) }

  let(:cocina_object) do
    cocina_object = Cocina::Models.build(
      {
        externalIdentifier: druid_fixture,
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: DescriptionCocinaBuilder.title(title: title_fixture),
          # Duplicate keywords will be normalized out.
          subject: DescriptionCocinaBuilder.keywords(keywords: keywords_fixture + [{ 'text' => 'MyBespokeKeyword' }]),
          contributor: [
            DescriptionCocinaBuilder.person_contributor(**person_contributor_fixture),
            DescriptionCocinaBuilder.organization_contributor(
              **organization_contributor_fixture
            ),
            DescriptionCocinaBuilder.organization_contributor(**degree_granting_contributor_fixture),
            {
              name: [{ value: 'Stanford University Press' }],
              # Publisher role is going to be normalized out.
              role: [
                {
                  code: 'pbl',
                  source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' },
                  uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                  value: 'publisher'
                }
              ],
              # Affiliation is going to be normalized out.
              note: [
                {
                  value: 'Stanford Internet Observatory',
                  type: 'affiliation'
                }
              ]
            },
            # Normalization will add ROR
            {
              name: [{ value: 'Stanford University' }],
              role: [
                {
                  code: 'dgg',
                  source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' },
                  uri: 'http://id.loc.gov/vocabulary/relators/dgg',
                  value: 'degree granting institution'
                }
              ],
              type: 'organization'
            }
          ],
          event: [
            DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-07/2022-04~'),
            {
              type: 'publication',
              date: [{ value: '2024-12', type: 'publication', status: 'primary', encoding: { code: 'edtf' } }],
              # Contributor will be normalized out.
              contributor: [{ name: [{ value: 'Stanford University Press' }] }]
            },
            # Deposit events will be normalized out.
            { date: [{ encoding: { code: 'edtf' }, type: 'publication', value: '2023-09-28' }], type: 'deposit' },
            { date: [{ encoding: { code: 'edtf' }, type: 'modification', value: '2023-09-28' }], type: 'deposit' },
            # Events without dates will be normalized out.
            { type: 'publication' }
          ],
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: abstract_fixture),
                 DescriptionCocinaBuilder.note(type: 'preferred citation',
                                               value: citation_fixture,
                                               # Preferred citation label will be normalized out.
                                               label: 'Preferred Citation')],
          relatedResource: DescriptionCocinaBuilder.related_works(related_works: related_works_fixture) +
                           DescriptionCocinaBuilder.related_links(related_links: related_links_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(contact_emails: contact_emails_fixture
              .append(ContactEmailForm.new(email: works_contact_email_fixture))) +

              # Duplicate will be normalized out.
              DescriptionCocinaBuilder.contact_emails(contact_emails: [ContactEmailForm.new(email: works_contact_email_fixture)])
          },
          form: [
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
          ],
          adminMetadata: {
            # Code will be normalized to edtf.
            event: [{ date: [{ encoding: { code: 'w3cdtf' }, value: '2023-05-09' }], type: 'creation' }],
            note: [
              {
                type: 'record origin',
                value: 'Metadata created by user via Stanford self-deposit application'
              }
            ]
          },
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 2,
        identification: { sourceId: source_id_fixture, doi: doi_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: {
          view: 'citation-only',
          download: 'none',
          license: license_fixture,
          # Nil location will be normalized out.
          location: nil,
          # Use and reproduction statement is absent.
          embargo: {
            # Nil location will be normalized out.
            view: 'stanford', download: 'stanford', releaseDate: release_date_fixture, location: nil
          },
          # Copyright will be normalized out.
          copyright: 'This work is copyrighted by the creator.'
        },
        structural: {
          contains: [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/file',
              externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
              label: 'My file',
              # Version will be normalized to match DRO version.
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file.text',
                    label: 'my_dir/my_file.txt', # Will be normalized to match fileset label.
                    filename: 'my_dir/my_file.txt',
                    size: file_size_fixture,
                    # Version will be normalized to match DRO version.
                    version: 1,
                    hasMimeType: 'text/plain',
                    sdrGeneratedText: false,
                    correctedForAccessibility: false,
                    hasMessageDigests: [
                      # Order of digests is reversed (like created by SDR API).
                      {
                        type: 'sha1',
                        digest: sha1_fixture
                      },
                      {
                        type: 'md5',
                        digest: md5_fixture
                      }
                    ],
                    access: {
                      view: 'dark',
                      download: 'none',
                      controlledDigitalLending: false,
                      # Nil location will be normalized out.
                      location: nil
                    },
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    },
                    # These will be normalized out.
                    languageTag: nil,
                    use: nil
                  }
                ]
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/file',
              externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85',
              label: 'My PDF file',
              version: 2,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85/my_pdf_file.pdf',
                    label: 'My PDF file',
                    filename: 'my_pdf_file.pdf',
                    size: file_size_fixture,
                    version: 2,
                    hasMimeType: 'application/pdf',
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
            }
          ],
          isMemberOf: [collection_druid_fixture]
        }
      }
    )
    Cocina::Models.with_metadata(cocina_object, lock_fixture)
  end

  let(:expected_cocina_object) do
    cocina_object = Cocina::Models.build(
      {
        externalIdentifier: druid_fixture,
        type: Cocina::Models::ObjectType.document,
        label: title_fixture,
        description: {
          title: DescriptionCocinaBuilder.title(title: title_fixture),
          subject: DescriptionCocinaBuilder.keywords(keywords: keywords_fixture),
          contributor: [
            DescriptionCocinaBuilder.person_contributor(**person_contributor_fixture),
            DescriptionCocinaBuilder.organization_contributor(**organization_contributor_fixture),
            DescriptionCocinaBuilder.organization_contributor(**degree_granting_contributor_fixture),
            { name: [{ value: 'Stanford University Press' }] },
            DescriptionCocinaBuilder.organization_contributor(
              role: 'degree_granting_institution',
              name: 'Stanford University'
            )
          ],
          event: [
            DescriptionCocinaBuilder.event(type: 'creation', date: '2021-03-07/2022-04~'),
            DescriptionCocinaBuilder.event(type: 'publication', date: '2024-12', primary: true)
          ],
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: abstract_fixture),
                 DescriptionCocinaBuilder.note(type: 'preferred citation', value: citation_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_works(related_works: related_works_fixture) +
                           DescriptionCocinaBuilder.related_links(related_links: related_links_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(
              contact_emails: contact_emails_fixture.append(ContactEmailForm.new(email: works_contact_email_fixture))
            )
          },
          form: [
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
          ],
          adminMetadata: DescriptionCocinaBuilder.admin_metadata(creation_date: deposit_creation_date_fixture),
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 2,
        identification: { sourceId: source_id_fixture, doi: doi_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'citation-only',
                  download: 'none',
                  license: license_fixture,
                  useAndReproductionStatement: I18n.t('license.terms_of_use'),
                  embargo: { view: 'stanford', download: 'stanford', releaseDate: release_date_fixture } },
        structural: {
          contains: [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/file',
              externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
              label: 'My file',
              version: 2,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file.text',
                    label: 'My file',
                    filename: 'my_dir/my_file.txt',
                    size: file_size_fixture,
                    version: 2,
                    hasMimeType: 'text/plain',
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
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/document',
              externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85',
              label: 'My PDF file',
              version: 2,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85/my_pdf_file.pdf',
                    label: 'My PDF file',
                    filename: 'my_pdf_file.pdf',
                    size: file_size_fixture,
                    version: 2,
                    hasMimeType: 'application/pdf',
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
            }
          ],
          isMemberOf: [collection_druid_fixture]
        }
      }
    )
    Cocina::Models.with_metadata(cocina_object, lock_fixture)
  end

  it 'normalizes cocina object' do
    expect(normalized_cocina_object).to equal_cocina(expected_cocina_object)
  end
end
