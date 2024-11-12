# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TableRowComponent, type: :component do
  it 'renders the row' do
    render_inline(described_class.new(values: ['First value', 'Second value']))
    expect(page).to have_css('td', count: 2)
  end
end
