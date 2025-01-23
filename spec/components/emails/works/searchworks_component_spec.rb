# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::SearchworksComponent, type: :component do
  it 'renders the Searchworks text' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'Your deposit will be available soon in SearchWorks')
  end
end
