# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::ChangesComponent, type: :component do
  it 'renders the changes text' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'If you need to make changes to your deposit, you can do so at http://test.host/.')
    expect(page).to have_link('http://test.host/', href: 'http://test.host/')
  end
end
