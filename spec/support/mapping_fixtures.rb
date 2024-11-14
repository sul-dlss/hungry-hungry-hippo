# frozen_string_literal: true

# Fixtures for mappings.
# Not using FactoryBot because we want these fixtures to be consistent across tests.
module MappingFixtures
  def work_form_fixture
    WorkForm.new(title: title_fixture)
  end

  def request_dro_fixture
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture)
        },
        version: 1,
        identification: { sourceId: source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world', download: 'world' }
      }
    )
  end

  # rubocop:disable Metrics/MethodLength
  def dro_fixture
    Cocina::Models.build(
      {
        externalIdentifier: druid_fixture,
        type: Cocina::Models::ObjectType.object,
        label: title_fixture,
        description: {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          purl: Sdr::Purl.from_druid(druid: druid_fixture)
        },
        version: 1,
        identification: { sourceId: source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world', download: 'world' },
        structural: {}
      }
    )
  end
  # rubocop:enable Metrics/MethodLength

  RSpec.configure do |config|
    config.include MappingFixtures, type: :mapping
  end
end
