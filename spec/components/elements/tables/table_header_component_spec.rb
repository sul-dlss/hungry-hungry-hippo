# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TableHeaderComponent, type: :component do
  it 'renders the row' do
    render_inline(described_class.new(classes: 'table-light', headers: ['First header', 'Second header'],
                                      each_classes: [nil, 'col-6']))
    expect(page).to have_css('thead', count: 1)
    expect(page).to have_css('th', count: 2)
    expect(page).to have_css('th:not(.col-6)', text: 'First header')
    expect(page).to have_css('th.col-6', text: 'Second header')
  end
end
