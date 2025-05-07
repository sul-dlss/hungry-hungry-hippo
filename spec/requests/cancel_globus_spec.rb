# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cancel globus' do
  let(:content) { create(:content, user:, work:) }

  let(:work) { create(:work) }

  let(:user) { create(:user) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      post "/contents/#{content.id}/globuses/cancel"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    before do
      content.globus_list!

      sign_in(user)
    end

    it 'redirects to globus new path' do
      post "/contents/#{content.id}/globuses/cancel"

      expect(response).to redirect_to("/contents/#{content.id}/globuses/new")

      expect(content.reload.globus_not_in_progress?).to be true
    end
  end
end
