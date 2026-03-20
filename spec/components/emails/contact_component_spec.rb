# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::ContactComponent, type: :component do
  it 'renders the contact information' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'Contact us with questions.')
    expect(page).to have_link('Contact us with questions.', href: 'http://test.host/contacts/new')
  end
end
