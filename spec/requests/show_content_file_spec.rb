# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show content file' do
  context 'when the user is not authorized' do
    let(:content_file) { create(:content_file) }

    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/content_files/#{content_file.id}"

      expect(response).to redirect_to(root_path)
    end
  end
end
