# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::Mapper do
  subject(:work_form) { described_class.call(cocina_object:) }

  let(:expected) { WorkForm.new(title: 'My Title') }

  let(:cocina_object) do
    build(:dro, title: 'My Title')
  end

  it 'maps to cocina' do
    expect(work_form).to equal_form(expected)
  end
end
