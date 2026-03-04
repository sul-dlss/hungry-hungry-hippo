# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractAbstractService, :vcr do
  # Note that VCR is configured to filter the Gemini API key from requests.
  subject(:abstract) { described_class.call(filepath:, raise_on_error:) }

  let(:raise_on_error) { false }
  let(:filepath) { 'spec/fixtures/files/Strategies_for_Digital_Library_Migration.pdf' }

  context 'when the abstract can be successfully extracted' do
    it 'returns the extracted abstract text' do
      abstract = described_class.call(filepath:)
      expect(abstract).to include('A migration of the datastore and data model for Stanford Digital Repository')
    end
  end

  context 'when the abstract cannot be extracted' do
    let(:filepath) do
      'spec/fixtures/files/mendenhall-hodge-1998-regulation-of-cdc28-cyclin-dependent-protein-kinase-activity.pdf'
    end

    it 'returns nil' do
      expect(abstract).to be_nil
    end
  end

  context 'when the abstract has multiple sections' do
    let(:filepath) do
      'spec/fixtures/files/Main_Text.pdf'
    end

    it 'returns the extracted abstract text with sections' do
      abstract = described_class.call(filepath:)

      expect(abstract).to match(/Background: Acute lymphoblastic leukemia.+\n\nObjective: This study aims.+\n\nMethods: A systematic search.+\n\nResults: Fifteen studies were included.+\n\nConclusion: Combining targeted therapies.+/) # rubocop:disable Layout/LineLength
    end
  end

  context 'when there is an error during extraction' do
    before do
      allow_any_instance_of(RubyLLM::Chat).to receive(:ask).and_raise(RubyLLM::Error) # rubocop:disable RSpec/AnyInstance
    end

    it 'returns nil' do
      expect(abstract).to be_nil
    end
  end

  context 'when there is an error during extraction and raise_on_error is true' do
    let(:raise_on_error) { true }

    before do
      allow_any_instance_of(RubyLLM::Chat).to receive(:ask).and_raise(RubyLLM::Error) # rubocop:disable RSpec/AnyInstance
    end

    it 'raises an error' do
      expect { abstract }.to raise_error(RubyLLM::Error)
    end
  end
end
