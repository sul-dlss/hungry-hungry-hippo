# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete content files' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'when the user is not authorized' do
    let(:content) { create(:content, :with_content_files) }

    it 'redirects to root and does not delete any files' do
      expect(content.content_files.count).to eq 2

      delete "/contents/#{content.id}"

      expect(response).to redirect_to(root_path)
      expect(content.content_files.count).to eq 2
    end
  end

  context 'when the user is authorized' do
    let(:content) { create(:content, :with_content_files, user:) }

    it 'destroys all of the content files' do
      expect(content.content_files.count).to eq 2

      delete "/contents/#{content.id}"

      expect(content.reload.content_files.count).to eq 0
    end
  end
end
