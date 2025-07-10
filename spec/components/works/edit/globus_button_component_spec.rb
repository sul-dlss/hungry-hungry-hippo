# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::GlobusButtonComponent, type: :component do
  context 'when confirm is false' do
    let(:confirm) { false }

    it 'does not require confirmation' do
      render_inline(described_class.new(confirm:, label: 'Use Globus to transfer files', link: 'content/path'))

      expect(page).to have_button('Use Globus to transfer files')
      expect(page).to have_css('form[data-action="dropzone-files#disableDropzone"]')
    end
  end

  context 'when confirm is true' do
    let(:confirm) { true }

    it 'does not require confirmation' do
      render_inline(described_class.new(confirm:, label: 'Use Globus to transfer files', link: 'content/path'))

      expect(page).to have_button('Use Globus to transfer files')
      expect(page).to have_css('form[data-action="dropzone-files#disableDropzoneConfirm"]')
    end
  end
end
