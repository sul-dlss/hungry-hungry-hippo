# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Builder do
  include WorkMappingFixtures

  subject(:content) { described_class.call(cocina_object: dro_with_structural_fixture(hide:), user:, work:) }

  let(:user) { create(:user) }
  let(:expected_content_file) { content_fixture(user:, hide:).content_files.first }
  let(:hide) { false }
  let(:work) { nil }

  context 'when file is not hidden' do
    it 'builds Content and Content Files model objects' do
      expect(content).to be_a(Content)
      expect(content.content_files.length).to eq(1)
      expect(content.dirty?).to be false

      content_file = content.content_files.first
      expect(content_file.hidden?).to be false
      # In addition to default ignored attributes, also ignore the content id.
      expect(content_file).to equal_model(expected_content_file, [:content_id])
    end
  end

  context 'when file is hidden' do
    let(:hide) { true }

    it 'builds Content and Content Files model objects' do
      expect(content).to be_a(Content)
      expect(content.content_files.length).to eq(1)
      expect(content.dirty?).to be false

      content_file = content.content_files.first
      expect(content_file.hidden?).to be true
      # In addition to default ignored attributes, also ignore the content id.
      expect(content_file).to equal_model(expected_content_file, [:content_id])
    end
  end

  context 'when a work is provided' do
    let(:work) { create(:work) }

    it 'associates the work with the content' do
      expect(content.work).to eq(work)
    end
  end
end
