# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'List recent activity' do
  let!(:work) { create(:work, :with_druid, object_updated_at: Time.zone.today) }
  let!(:old_work) { create(:work, :with_druid, updated_at: 40.days.ago) }
  let!(:collection) { create(:collection, :with_druid) }

  before do
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  describe 'GET /admin/recent_activity' do
    context 'when viewing works' do
      it 'shows the most recent works with activity' do
        get '/admin/recent_activity?admin_recent_activity[type]=works'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Items recent activity')
        expect(response.body).to include(work.title)
        expect(response.body).to include("/works/#{work.druid}")
      end
    end

    context 'when viewing collections' do
      it 'shows the most recent collections with activity' do
        get '/admin/recent_activity?admin_recent_activity[type]=collections'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Collections recent activity')
        expect(response.body).to include(collection.title)
        expect(response.body).to include("/collections/#{collection.druid}")
        expect(response.body).not_to include(old_work.title)
        expect(response.body).not_to include("/works/#{old_work.druid}")
      end
    end
  end
end
