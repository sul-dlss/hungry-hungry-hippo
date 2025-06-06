# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Generate item report' do
  describe 'GET /admin/work_report/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/work_report/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'shows admin generate item report form' do
        get '/admin/work_report/new'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'when submitting the form' do
    before do
      sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
    end

    context 'when form is valid' do
      it 'redirects to new form' do
        post '/admin/work_report', params: { admin_work_report: { date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false }}

        expect(flash[:success]).to eq(I18n.t('messages.work_report_generated'))
        expect(response).to redirect_to(new_admin_work_report_path)
      end
    end

    context 'when form is not valid' do
      it 'redirects to new form' do
        post '/admin/work_report', params: { admin_work_report: { date_created_start: 'not a date', date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false }}
        expect(response).to redirect_to(new_admin_work_report_path)
      end
    end
  end
end