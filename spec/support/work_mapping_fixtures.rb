# frozen_string_literal: true

# Fixtures for mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
# rubocop:disable Metrics/ModuleLength
module WorkMappingFixtures
  def new_work_form_fixture
    WorkForm.new(
      title: title_fixture,
      abstract: abstract_fixture,
      related_links_attributes: related_links_fixture,
      license: license_fixture,
      collection_druid: collection_druid_fixture
    )
  end

  def work_form_fixture
    new_work_form_fixture.tap do |form|
      form.druid = druid_fixture
      form.version = 2
      form.lock = lock_fixture
    end
  end

  # No external identifiers
  def new_content_fixture(user: nil)
    content = Content.create!(user: user || create(:user))
    ContentFile.create(
      file_type: 'attached',
      content: content,
      filename: filename_fixture,
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
      content: content,
      filename: filename_fixture,
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

  def request_dro_fixture
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture)],
          relatedResource: CocinaDescriptionSupport.related_links(related_links: related_links_fixture)
        },
        version: 1,
        identification: { sourceId: source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world', download: 'world', license: license_fixture,
                  useAndReproductionStatement: I18n.t('works.edit.fields.license.terms_of_use') },
        structural: { isMemberOf: [collection_druid_fixture] }
      }
    )
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
                                        view: 'world',
                                        download: 'world',
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

  def dro_fixture
    Cocina::Models.build(
      {

        externalIdentifier: druid_fixture,
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture)],
          relatedResource: CocinaDescriptionSupport.related_links(related_links: related_links_fixture),
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 2,
        identification: { sourceId: source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world',
                  download: 'world',
                  license: license_fixture,
                  useAndReproductionStatement: I18n.t('works.edit.fields.license.terms_of_use') },
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
                                  view: 'world',
                                  download: 'world',
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
# rubocop:enable Metrics/ModuleLength
