# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Stager do
  let(:druid) { druid_fixture }
  let(:content) do
    create(:content, content_files: [deposited_file, attached_file, hierarchical_attached_file, globus_file])
  end

  let!(:deposited_file) { create(:content_file) }
  let(:attached_file) { create(:content_file, :attached, filepath: 'my_file1.txt') }
  let(:hierarchical_attached_file) { create(:content_file, :attached, filepath: 'my_dir/my_file2.txt') }
  let(:globus_file) { create(:content_file, file_type: :globus, filepath: 'hippo.svg') }

  let(:object_path) { 'tmp/workspace/bc/123/df/4567/bc123df4567' }

  before do
    FileUtils.rm_rf(object_path)

    allow(globus_file).to receive(:filepath_on_disk).and_return('spec/fixtures/files/hippo.svg')
  end

  it 'stages the files' do
    described_class.call(content:, druid:)

    expect(File.exist?(File.join(object_path, 'content/my_file1.txt'))).to be true
    expect(File.exist?(File.join(object_path, 'content/my_dir/my_file2.txt'))).to be true
    expect(File.exist?(File.join(object_path, 'content/hippo.svg'))).to be true
    expect(File.exist?(File.join(object_path, 'content', deposited_file.filepath))).to be false
  end
end
