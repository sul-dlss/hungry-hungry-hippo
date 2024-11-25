# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Stager do
  let(:druid) { druid_fixture }
  let(:content) { create(:content) }

  let!(:attached_file) { create(:content_file, :attached, content: content) }
  let!(:deposited_file) { create(:content_file, content: content) }

  let(:object_path) { 'tmp/workspace/bc/123/df/4567/bc123df4567' }

  before do
    FileUtils.rm_rf(object_path)
  end

  it 'stages the files' do
    described_class.call(content: content, druid: druid)

    expect(File.exist?(File.join(object_path, 'content', attached_file.filename))).to be true
    expect(File.exist?(File.join(object_path, 'content', deposited_file.filename))).to be false
  end
end
