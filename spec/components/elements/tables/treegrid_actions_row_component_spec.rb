# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TreegridActionsRowComponent, type: :component do
  it 'renders the expand/collapse actions row' do
    render_inline(described_class.new(colspan: 4))

    expect(page).to have_css('tr')
    expect(page).to have_css('td[colspan="4"]')
    expect(page).to have_button('Expand all')
    expect(page).to have_button('Collapse all')
  end

  it 'uses default colspan of 1' do
    render_inline(described_class.new)

    expect(page).to have_css('td[colspan="1"]')
  end
end
