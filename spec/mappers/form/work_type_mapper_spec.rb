# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::WorkTypeMapper do
  subject(:work_type_params) { described_class.call(cocina_object:) }

  let(:dro) { build(:dro) }
  let(:cocina_object) do
    dro.new(
      description: dro.description.new(
        form: [
          {
            value: 'Data',
            source: { value: Cocina::WorkTypesMapper::RESOURCE_TYPE_SOURCE_LABEL },
            type: 'resource type'
          }
        ]
      )
    )
  end

  it 'maps a direct self-deposit resource type to the form' do
    expect(work_type_params).to eq(work_type: 'Data', work_subtypes: [])
  end
end
