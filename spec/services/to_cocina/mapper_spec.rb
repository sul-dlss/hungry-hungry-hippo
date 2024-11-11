# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Mapper do
  subject(:cocina_object) { described_class.call(work_form:, source_id:) }

  let(:source_id) { "h3:object-#{Time.zone.now.iso8601}" }

  context 'with a new work' do
    let(:work_form) { WorkForm.new(title: 'My Title') }

    let(:expected) do
      Cocina::Models.build_request(
        {
          type: Cocina::Models::ObjectType.object,
          label: 'My Title',
          description: {
            title: CocinaDescriptionSupport.title(title: 'My Title')
          },
          version: 1,
          identification: { sourceId: source_id },
          administrative: { hasAdminPolicy: Settings.apo },
          access: { view: 'world', download: 'world' }
        }
      )
    end

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
