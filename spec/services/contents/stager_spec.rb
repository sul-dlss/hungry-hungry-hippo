# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contents::Stager do
  let(:druid) { druid_fixture }
  let(:content) { create(:content) }

  let!(:deposited_file) { create(:content_file, content:) }

  let(:object_path) { 'tmp/workspace/bc/123/df/4567/bc123df4567' }

  before do
    FileUtils.rm_rf(object_path)

    create(:content_file, :attached, content:, filepath: 'my_file1.txt')
    create(:content_file, :attached, content:, filepath: 'my_dir/my_file2.txt')
  end

  it 'stages the files' do
    described_class.call(content:, druid:)

    expect(File.exist?(File.join(object_path, 'content/my_file1.txt'))).to be true
    expect(File.exist?(File.join(object_path, 'content/my_dir/my_file2.txt'))).to be true
    expect(File.exist?(File.join(object_path, 'content', deposited_file.filepath))).to be false
  end
end
