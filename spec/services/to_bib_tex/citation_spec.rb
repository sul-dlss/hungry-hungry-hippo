# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToBibTex::Citation, type: :mapping do
  subject(:bibtex) { described_class.call(cocina_object:) }
 
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:citation) { 'My title. (2024).' }

  it 'maps to BibTex' do
    expect(bibtex.first.to_s).to equal(citation)
  end
end
