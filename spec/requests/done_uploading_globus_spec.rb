# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Done uploading globus' do
  let(:content) { create(:content, user:, work:) }

  let(:work) { create(:work, :with_druid) }
  let(:user) { create(:user) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      post "/contents/#{content.id}/globuses/done_uploading"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    before do
      allow(GlobusListJob).to receive(:perform_later)
      sign_in(user)
    end

    context 'when a transfer is not in progress' do
      before do
        allow(GlobusClient).to receive(:tasks_in_progress?).and_return(false)
      end

      it 'redirects to globus wait path' do
        post "/contents/#{content.id}/globuses/done_uploading"

        expect(response).to redirect_to("/contents/#{content.id}/globuses/wait")

        expect(GlobusListJob).to have_received(:perform_later).with(content:, ahoy_visit: Ahoy::Visit.last)
        expect(GlobusClient).to have_received(:tasks_in_progress?)
          .with(destination_path: "/uploads/work-#{work.id}")
      end
    end

    context 'when a transfer is in progress' do
      before do
        allow(GlobusClient).to receive(:tasks_in_progress?).and_return(true)
      end

      it 'redirects to globus wait path' do
        post "/contents/#{content.id}/globuses/done_uploading"

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Transfers in progress.')

        expect(GlobusListJob).not_to have_received(:perform_later).with(content:)
      end
    end
  end
end
