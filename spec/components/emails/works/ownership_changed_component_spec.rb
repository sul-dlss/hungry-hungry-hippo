# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::OwnershipChangedComponent, type: :component do
  let(:work) { create(:work, druid: druid_fixture) }
  let(:link_to_work) { 'http://test.host/works/druid:bc123df4567' }

  it 'renders the ownership changed text' do
    render_inline(described_class.new(work:))

    expect(page).to have_css('p', text: "You are now the owner of the item \"#{link_to_work}\" " \
                                        'in the Stanford Digital Repository and have access to ' \
                                        'manage its metadata and files. ' \
                                        "Click #{link_to_work} to view or edit this item.")
    expect(page).to have_link(link_to_work, href: link_to_work)
  end
end
