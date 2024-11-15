# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit work' do
  context 'when the deposit job started' do
    let!(:work) { create(:work, :deposit_job_started, druid: 'druid:bc123df4567') }

    before do
      sign_in(create(:user))
    end

    it 'redirects to waiting page' do
      get '/works/druid:bc123df4567/edit'

      expect(response).to redirect_to(wait_works_path(work.id))
    end
  end
end
