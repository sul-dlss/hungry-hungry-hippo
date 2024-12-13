# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToBibTex::Citation, type: :mapping do
  subject(:bibtex) { described_class.call(cocina_object:) }

  let(:cocina_object) { dro_with_metadata_fixture }

  it 'maps to BibTex' do
    debugger
    expect(bibtex).to equal(bibtex)
  end
end
