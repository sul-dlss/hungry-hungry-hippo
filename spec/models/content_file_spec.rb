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

  describe '.staging_filepath' do
    let(:work) { create(:work, :with_druid) }
    let(:content) { create(:content, :with_content_files, work:) }
    let(:content_file) { content.content_files.first }

    it 'returns the path in the staging area' do
      expect(content_file.staging_filepath).to eq StagingSupport.staging_filepath(druid: work.druid,
                                                                                  filepath: content_file.filepath)
    end
  end
end
