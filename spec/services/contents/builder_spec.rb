# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Builder do
  include MappingFixtures

  subject(:content) { described_class.call(cocina_object: dro_with_structural_fixture) }

  let(:expected_content_file) { content_fixture.content_files.first }

  it 'builds Content and Content Files model objects' do
    expect(content).to be_a(Content)
    expect(content.content_files.length).to eq(1)

    content_file = content.content_files.first
    # In addition to default ignored attributes, also ignore the content id.
    expect(content_file).to equal_model(expected_content_file, [:content_id])
  end
end
