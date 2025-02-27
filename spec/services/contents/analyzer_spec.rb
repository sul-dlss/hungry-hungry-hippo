# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Analyzer do
  let(:content) { create(:content) }
  let!(:attached_file) { create(:content_file, :attached, content:) }
  let!(:deposited_file) { create(:content_file, content:) }

  it 'adds missing digests and mime types' do
    described_class.call(content:)

    expect(attached_file.reload.md5_digest).to eq('27f74b7c51a39f3702933461eb7a5fbb')
    expect(attached_file.reload.sha1_digest).to eq('ad9e7baab12fb05596614489054ced4d9bcbcf3d')
    expect(attached_file.reload.mime_type).to eq('image/png')

    # Skips deposited files
    expect(deposited_file.reload.md5_digest).to be_nil
    expect(deposited_file.reload.sha1_digest).to be_nil
    expect(deposited_file.reload.mime_type).to be_nil
  end
end
