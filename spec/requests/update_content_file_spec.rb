# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update content file' do
  context 'when the user is not authorized' do
    let(:content_file) { create(:content_file) }

    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      patch "/content_files/#{content_file.id}"

      expect(response).to redirect_to(root_path)
    end
  end
end
