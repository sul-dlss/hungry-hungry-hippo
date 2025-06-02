# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::ContentFileDownloadButtonComponent, type: :component do
  let(:content_file) { create(:content_file, :deposited, filepath: 'test.txt', content:) }
  let(:work) { create(:work, druid:) }
  let(:druid) { druid_fixture }
  let(:content) { create(:content, work:) }

  context 'when content file not available for download' do
    it 'does not render' do
      render_inline(described_class.new(content_file:))

      expect(page).to have_no_css('a')
    end
  end

  context 'when content file is available for download' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('tmp/workspace/bc/123/df/4567/bc123df4567/content/test.txt').and_return(true)
    end

    it 'renders link' do
      render_inline(described_class.new(content_file:))

      expect(page).to have_link('Download file', href: "/content_files/#{content_file.id}/download")
      expect(page).to have_css('a[data-turbo="false"]')
    end
  end
end
