# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Mapper, type: :mapping do
  subject(:cocina_object) { described_class.call(work_form:, source_id: source_id_fixture) }

  context 'with a new work' do
    let(:work_form) { new_work_form_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_dro_fixture)
    end
  end

  context 'with a work' do
    let(:work_form) { work_form_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(dro_with_metadata_fixture)
    end
  end
end
