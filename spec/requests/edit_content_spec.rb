# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit content' do
  context 'when the user is not authorized' do
    let(:content) { create(:content) }

    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/contents/#{content.id}/edit"

      expect(response).to redirect_to(root_path)
    end
  end
end
