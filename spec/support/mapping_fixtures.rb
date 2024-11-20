# frozen_string_literal: true

# Fixtures for mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module MappingFixtures
  def new_work_form_fixture
    WorkForm.new(
      title: title_fixture,
      abstract: abstract_fixture,
      related_links: related_links_fixture
    )
  end

  def work_form_fixture
    new_work_form_fixture.tap do |form|
      form.druid = druid_fixture
      form.version = 2
      form.lock = lock_fixture
    end
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
        access: { view: 'world', download: 'world' },
        structural: {}
      }
    )
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
        access: { view: 'world', download: 'world' },
        structural: {}
      }
    )
  end

  def dro_with_metadata_fixture
    Cocina::Models.with_metadata(dro_fixture, lock_fixture)
  end

  RSpec.configure do |config|
    config.include MappingFixtures, type: :mapping
  end
end
