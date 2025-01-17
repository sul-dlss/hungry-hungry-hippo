# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::WorksListComponent, type: :component do
  let(:work) do
    create(:work, user: current_user, collection:, druid: druid_fixture,
                  object_updated_at: Time.zone.parse('2024-12-3'))
  end
  let(:work_without_druid) { create(:work, user: current_user, collection:) }
  let(:collection) { create(:collection) }
  let(:current_user) { create(:user) }
  let(:version_status) { instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 1) }
  let(:status_map) do
    {
      work.id => VersionStatus.new(status: version_status),
      work_without_druid.id => VersionStatus::NilStatus.new
    }
  end

  it 'renders the works list table with rows' do
    render_inline(described_class.new(collection:, status_map:))

    table = page.find('table')
    expect(table).to have_css('th', text: 'Recent deposits in collection')
    expect(table).to have_css('th', text: 'Deposit status')
    expect(table).to have_css('th', text: 'Owner')
    expect(table).to have_css('th', text: 'Last modified')
    expect(table).to have_css('th', text: 'Link for sharing')
    table_body = table.find('tbody')
    expect(table_body).to have_css('tr', count: 2)
    first_row = table_body.find('tr:nth-of-type(1)')
    expect(first_row).to have_css('td:nth-of-type(1)', text: work.title)
    expect(first_row).to have_link(work.title, href: "/works/#{work.druid}")
    expect(first_row).to have_css('td:nth-of-type(2)', text: 'Draft - Not deposited')
    expect(first_row).to have_css('td:nth-of-type(4)', text: 'Dec 03, 2024')
    expect(first_row).to have_css('td:nth-of-type(5)', text: Sdr::Purl.from_druid(druid: work.druid))
    second_row = table_body.find('tr:nth-of-type(2)')
    expect(second_row).to have_css('td:nth-of-type(1)', text: work_without_druid.title)
    expect(second_row).to have_link(work_without_druid.title, href: "/works/wait/#{work_without_druid.id}")
    expect(second_row).to have_css('td:nth-of-type(2)', text: 'Saving')
    expect(second_row).to have_css('td:nth-of-type(5)', text: '') # No PURL
  end
end
