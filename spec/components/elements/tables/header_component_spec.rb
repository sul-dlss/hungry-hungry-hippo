# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::HeaderComponent, type: :component do
  it 'renders the row' do
    render_inline(described_class.new(classes: 'col-6', label: 'First header', tooltip: 'First tooltip'))

    expect(page).to have_css('th.col-6', text: 'First header')
    expect(page).to have_css('.tooltip-info[data-bs-title="First tooltip"]')
  end
end
