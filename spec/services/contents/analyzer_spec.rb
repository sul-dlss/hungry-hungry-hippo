# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Analyzer do
  let(:content) { create(:content, content_files: [attached_file, deposited_file, globus_file]) }
  let!(:attached_file) { create(:content_file, :attached) }
  let!(:deposited_file) { create(:content_file) }
  let(:globus_file) { create(:content_file, file_type: :globus) }

  before do
    allow(globus_file).to receive(:filepath_on_disk).and_return('spec/fixtures/files/hippo.tiff')
  end

  it 'adds missing digests and mime types' do
    described_class.call(content:)

    expect(attached_file.reload.md5_digest).to eq('27f74b7c51a39f3702933461eb7a5fbb')
    expect(attached_file.sha1_digest).to eq('ad9e7baab12fb05596614489054ced4d9bcbcf3d')
    expect(attached_file.mime_type).to eq('image/png')

    expect(globus_file.reload.md5_digest).to eq('1485816bdeb4ffca6bc6b7830daa7186')
    expect(globus_file.sha1_digest).to eq('b83dd4fe5b4c6d0724b8ff1c526a1a776f060b76')
    expect(globus_file.mime_type).to eq('image/tiff')

    # Skips deposited files
    expect(deposited_file.reload.md5_digest).to be_nil
    expect(deposited_file.sha1_digest).to be_nil
    expect(deposited_file.mime_type).to be_nil
  end
end
