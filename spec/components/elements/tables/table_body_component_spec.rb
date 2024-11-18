# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TableBodyComponent, type: :component do
  let(:work) { create(:work) }
  let(:rows) { [work.title] }

  it 'renders the body' do
    render_inline(described_class.new(rows:))
    expect(page).to have_css('tbody', count: 1)
    expect(page).to have_css('tr', count: 1)
    expect(page).to have_css('tr', text: work.title)
  end
end
