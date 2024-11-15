# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::Mapper, type: :mapping do
  subject(:work_form) { described_class.call(cocina_object:) }

  let(:cocina_object) { dro_fixture }

  it 'maps to cocina' do
    expect(work_form).to equal_form(work_form_fixture)
  end
end
