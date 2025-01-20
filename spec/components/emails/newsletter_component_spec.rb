# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::NewsletterComponent, type: :component do
  it 'renders the newsletter' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'Subscribe to the SDR newsletter for feature updates, tips, and related news.')
    expect(page).to have_link('Subscribe to the SDR newsletter', href: Settings.newsletter_url)
  end
end
