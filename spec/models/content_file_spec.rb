# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ContentFile do
  describe '.filepath_on_disk' do
    context 'when the file is attached' do
      let(:content_file) { create(:content_file, :attached) }

      it 'returns the file path on disk' do
        expect(content_file.filepath_on_disk).to eq(ActiveStorageSupport.filepath_for_blob(content_file.file.blob))
      end
    end

    context 'when the file is globus' do
      let(:work) { create(:work) }
      let(:content) { create(:content, work:) }
      let(:content_file) { create(:content_file, :globus, content:) }

      it 'returns the globus local path' do
        expect(content_file.filepath_on_disk).to eq("work-#{work.id}/#{content_file.filepath}")
      end
    end

    context 'when the file is not attached or globus' do
      let(:content_file) { create(:content_file, :deposited) }

      it 'returns nil' do
        expect(content_file.filepath_on_disk).to be_nil
      end
    end
  end
end
