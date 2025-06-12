# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show collection works' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/collections/#{druid}/works"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    let(:depositor) { create(:user) }

    before do
      create(:collection, druid:, depositors: [depositor])
      sign_in(depositor)
    end

    it 'shows the collection' do
      get "/collections/#{druid}/works"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="collection-works">')
      expect(response.body).to include('No deposits to this collection.')
    end
  end

  describe 'search' do
    let(:manager) { create(:user) }
    let(:depositor) { create(:user) }
    let(:contributor) { create(:person_contributor, first_name: 'Jane', last_name: 'Stanford', orcid: 'https://orcid.org/0001-0002-0003-0004') }

    let!(:collection) do
      create(:collection, :with_review_workflow, :with_works, :with_required_types,
             :with_required_contact_email, works_count: 3, reviewers_count: 2, druid:, title: collection_title_fixture,
                                           contributors: [contributor], managers: [manager], depositors: [depositor])
    end
    let(:works) { collection.works.order(:title) }

    let(:cocina_object) { collection_with_metadata_fixture }
    let(:version_status) { build(:openable_version_status) }

    let(:events) do
      # This is testing the case in which the data is a cocina object (e.g., registration event)
      [Dor::Services::Client::Events::Event.new(event_type: 'version_close', timestamp: '2020-01-27T19:10:27.291Z',
                                                data: { 'who' => 'lstanfordjr', 'cocinaVersion' => '0.1',
                                                        'description' => 'cocina description' })]
    end

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:statuses)
        .and_return(collection.works.where.not(druid: nil).to_h { |work| [work.druid, version_status] })
      allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)

      collection.works.first.request_review!
      collection.works[1].update(user: depositor)
    end

    context 'when the user is a collection manager' do
      before do
        sign_in(manager)
      end

      it 'returns all applicable results in the collection' do
        get "/collections/#{druid}/works" # no query
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(works.to_a[0].title)
        expect(response.body).to include(works.to_a[1].title)

        query = works.to_a[0].title
        get "/collections/#{druid}/works", params: { q: query }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[1].druid
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[2].title
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[2].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = 'asdfsdf'
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)

        query = works.to_a[0].user.email_address
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[1].user.name
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[2].user.first_name
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[2].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        get "/collections/#{druid}/works", params: { q: '' } # clear search
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(works.to_a[0].title)
        expect(response.body).to include(works.to_a[1].title)
      end
    end

    context 'when the user is a depositor' do
      before do
        sign_in(depositor)
      end

      it 'returns only the results owned by the user' do
        query = works.to_a[0].title
        get "/collections/#{druid}/works", params: { q: query }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)

        # the user in question only owns this work
        query = works.to_a[1].druid
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[1].druid)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[2].title
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[1].title)

        query = 'asdfsdf'
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)

        query = works.to_a[0].user.email_address
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)

        # the user in question only owns this work
        query = works.to_a[1].user.name
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(works.to_a[1].druid)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')

        query = works.to_a[2].user.first_name
        get "/collections/#{druid}/works", params: { q: query }
        expect(response.body).to include(/No deposits to this collection match the search: .*#{query}/)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[1].title)
        expect(response.body).not_to include(works.to_a[2].title)

        get "/collections/#{druid}/works", params: { q: '' } # clear search
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(works.to_a[1].druid)
        expect(response.body).not_to include(works.to_a[0].title)
        expect(response.body).not_to include(works.to_a[2].title)
        expect(response.body).not_to include('No deposits to this collection match the search')
      end
    end
  end
end
