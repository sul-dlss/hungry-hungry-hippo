# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractAbstractService, :vcr do
  # Note that VCR is configured to filter the Gemini API key from requests.
  subject(:abstract) { described_class.call(filepath:) }

  let(:filepath) { 'spec/fixtures/files/Strategies_for_Digital_Library_Migration.pdf' }

  context 'when the abstract can be successfully extracted' do
    it 'returns the extracted abstract text' do
      abstract = described_class.call(filepath:)
      expect(abstract).to include('A migration of the datastore and data model for Stanford Digital Repository')
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
end
