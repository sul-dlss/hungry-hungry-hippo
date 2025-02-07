# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show dashboard' do
  let(:user) { create(:user) }

  describe 'drafts section' do
    let!(:work) { create(:work, :with_druid, user:, collection:) }
    let(:collection) { create(:collection, :with_druid, user:, managers: [user]) }
    let(:drafts_header) { 'Drafts - please complete' }

    before do
      allow(Sdr::Repository).to receive(:statuses)
        .with(druids: [work.druid]).and_return({ work.druid => version_status })
    end

    context 'when there are drafts' do
      let(:version_status) do
        VersionStatus.new(status:
        instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 2))
      end

      before do
        sign_in(user)
      end

      it 'includes the drafts section' do
        get '/dashboard'

        expect(response.body).to include(drafts_header)
      end
    end

    context 'when there are no drafts' do
      let(:version_status) do
        VersionStatus.new(status:
        instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                             accessioning?: false))
      end

      before do
        sign_in(user)
      end

      it 'excludes the drafts section' do
        get '/dashboard'

        expect(response.body).not_to include(drafts_header)
      end
    end
  end

  describe 'create new collection button' do
    let(:button_text) { 'Create a new collection' }

    context 'when the user has permission to create collections' do
      before do
        sign_in(user, groups: [Settings.authorization_workgroup_names.administrators])
      end

      it 'renders the create a new collection button' do
        get '/dashboard'

        expect(response.body).to include(button_text)
      end
    end

    context 'when the user does not have permission to create collections' do
      before do
        sign_in(user)
      end

      it 'does not render the create a new collection button' do
        get '/dashboard'

        expect(response.body).not_to include(button_text)
      end
    end
  end

  describe 'policy' do
    let(:groups) { [] }

    before do
      sign_in(user, groups:)
    end

    context 'when user is an administrator' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }

      it 'renders the dashboard' do
        get '/dashboard'

        expect(response.body).to include('Dashboard')
        expect(response.body).not_to include('Welcome')
      end
    end

    context 'when user is a collection creator' do
      let(:groups) { [Settings.authorization_workgroup_names.collection_creators] }

      it 'renders the dashboard' do
        get '/dashboard'

        expect(response.body).to include('Dashboard')
        expect(response.body).not_to include('Welcome')
      end
    end

    context 'when user is a collection depositor' do
      before do
        create(:collection, :with_druid, user:, depositors: [user])
      end

      it 'renders the dashboard' do
        get '/dashboard'

        expect(response.body).to include('Dashboard')
        expect(response.body).not_to include('Welcome')
      end
    end

    context 'when user is a collection reviewer' do
      before do
        create(:collection, :with_druid, user:, reviewers: [user])
      end

      it 'renders the dashboard' do
        get '/dashboard'

        expect(response.body).to include('Dashboard')
        expect(response.body).not_to include('Welcome')
      end
    end

    context 'when user is a collection manager' do
      before do
        create(:collection, :with_druid, user:, managers: [user])
      end

      it 'renders the dashboard' do
        get '/dashboard'

        expect(response.body).to include('Dashboard')
        expect(response.body).not_to include('Welcome')
      end
    end

    context 'when user has none of the above roles' do
      it 'renders the new user form' do
        get '/dashboard'

        expect(response.body).not_to include('Dashboard')
        expect(response.body).to include('<turbo-frame id="contact-form" src="/contacts/new?welcome=true">')
      end
    end
  end
end
