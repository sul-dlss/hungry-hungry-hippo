# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerators::Description::OrganizationContributor do
  context 'with conference role' do
    subject(:cocina_params) { described_class.call(name: 'RailsConf', role: 'conference') }

    it 'creates Cocina::Models::Contributor params without marc relator role' do
      expect(cocina_params).to eq(
        {
          name: [{ value: 'RailsConf' }],
          type: 'conference',
          role: [
            {
              value: 'conference'
            }
          ]
        }
      )
    end
  end
end
