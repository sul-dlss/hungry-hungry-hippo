# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Github::ReleaseDownloader, :vcr do
  subject(:downloader) { described_class.new(zip_url:) }

  let(:zip_url) { 'https://api.github.com/repos/sul-dlss/hungry-hungry-hippo/zipball/v0.1.0' }

  describe '#exist?' do
    context 'when the zip file exists' do
      it 'returns true' do
        expect(downloader.exist?).to be true
      end
    end

    context 'when the zip file does not exist' do
      let(:zip_url) { 'https://api.github.com/repos/sul-dlss/hungry-hungry-hippo/zipball/nonexistent' }

      it 'returns false' do
        expect(downloader.exist?).to be false
      end
    end

    context 'when there is an error accessing the zip file' do
      let(:zip_url) { 'https://api.github.com/repos/sul-dlss/hungry-hungry-hippo/zipball/error' }

      before do
        stub_request(:head, zip_url).to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises a ReleaseDownloaderError' do
        expect do
          downloader.exist?
        end.to raise_error(Github::ReleaseDownloader::ReleaseDownloaderError, /Failed to access release zip/)
      end
    end
  end

  describe '#download_to' do
    let(:tempfile) { Tempfile.new(['release', '.zip'], binmode: true) }

    after do
      tempfile.close
      tempfile.unlink
    end

    context 'when the download is successful' do
      it 'downloads the zip file to the specified location' do
        downloader.download_to(tempfile)
        expect(File).to exist(tempfile)
        expect(File.size(tempfile)).to be > 0
      end
    end

    context 'when there is an error during download' do
      let(:zip_url) { 'https://api.github.com/repos/sul-dlss/hungry-hungry-hippo/zipball/error' }

      before do
        stub_request(:get, zip_url).to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises a ReleaseDownloaderError' do
        expect do
          downloader.download_to(tempfile)
        end.to raise_error(Github::ReleaseDownloader::ReleaseDownloaderError, /Failed to download release zip/)
      end
    end
  end
end
