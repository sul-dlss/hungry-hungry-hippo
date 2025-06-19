# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Generate collection report' do
  describe 'GET /admin/collection_report/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/collection_report/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'shows admin generate collection report form' do
        get '/admin/collection_report/new'

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
        post '/admin/collection_report', params: { admin_collection_report: { date_created_start: nil,
                                                                              date_created_end: nil,
                                                                              date_modified_start: nil,
                                                                              date_modified_end: nil } }

        expect(flash[:success]).to eq(I18n.t('messages.collection_report_generated'))
        expect(response).to redirect_to(new_admin_collection_report_path)
      end
    end

    context 'when form is not valid' do
      it 'redirects to new form' do
        post '/admin/collection_report', params: { admin_collection_report: { date_created_start: 'not a date',
                                                                              date_created_end: nil,
                                                                              date_modified_start: nil,
                                                                              date_modified_end: nil } }
        expect(response).to redirect_to(new_admin_collection_report_path)
      end
    end
  end
end
