require 'rails_helper'

RSpec.describe LegacyCollectionNormalizer do
  let(:normalized_cocina_object) { described_class.call(cocina_object:) }

  let(:cocina_object) do
    cocina_object = Cocina::Models.build(
      {
        externalIdentifier: collection_druid_fixture,
        type: Cocina::Models::ObjectType.collection,
        label: 'not the title',
        description: {
          title: DescriptionCocinaBuilder.title(title: collection_title_fixture),
          note: [DescriptionCocinaBuilder.note(type: 'abstract', value: collection_description_fixture)],
          relatedResource: DescriptionCocinaBuilder.related_links(related_links: related_links_fixture),
          access: {
            accessContact: DescriptionCocinaBuilder.contact_emails(contact_emails: contact_emails_fixture)

          },
          form: [
            {
              structuredValue: [
                {
                  value: 'Image',
                  type: 'type'
                }
              ],
              type: 'resource type',
              source: {
                value: 'Stanford self-deposit resource types'
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
          # Contributor will be normalized out.
          contributor: [DescriptionCocinaBuilder.person_contributor(**person_contributor_fixture)],
          purl: Sdr::Purl.from_druid(druid: collection_druid_fixture)
        },
        version: 2,
        identification: { sourceId: collection_source_id_fixture },
        administrative: { hasAdminPolicy: Settings.apo },
        access: {
          view: 'world',
          # Copyright, use and reproduction statement, and license will be normalized out.
          copyright: 'This work is copyrighted by the creator.',
          useAndReproductionStatement: 'This document is available only to the Stanford faculty, staff and student community.',
          license: 'https://creativecommons.org/licenses/by-nc/3.0/legalcode'
        }
      }
    )
    Cocina::Models.with_metadata(cocina_object, lock_fixture)
  end

  let(:expected_cocina_object) do
    cocina_object = Cocina::Models.build(
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
        administrative: { hasAdminPolicy: Settings.apo },
        access: { view: 'world' }
      }
    )
    Cocina::Models.with_metadata(cocina_object, lock_fixture)
  end

  it 'normalizes cocina object' do
    expect(normalized_cocina_object).to equal_cocina(expected_cocina_object)
  end
end
