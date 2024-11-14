# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Mapper, type: :mapping do
  subject(:cocina_object) { described_class.call(work_form: new_work_form_fixture, source_id: source_id_fixture) }

  context 'with a new work' do
    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_dro_fixture)
    end
  end
end
