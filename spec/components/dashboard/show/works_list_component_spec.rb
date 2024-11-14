# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::WorksListComponent, type: :component do
  let(:work) { create(:work) }
  let(:current_user) { create(:user) }

  it 'renders the works list table with rows' do
    render_inline(described_class.new(label: 'Your works', current_user:))

    expect(page).to have_css('h3', text: 'Your works')

    within('table#user-works') do
      expect(page).to have_no_css('thead')
      expect(page).to have_css('tr', count: 1)
      within('tr:nth-child(1)') do
        expect(page).to have_css('td', text: work.title)
      end
    end
  end
end
