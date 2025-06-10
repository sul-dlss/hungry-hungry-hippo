# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::PurlComponent, type: :component do
  let(:work) { create(:work, druid: druid_fixture) }

  it 'renders the PURL text' do
    render_inline(described_class.new(work:))

    expect(page).to have_css('p', text: 'The public webpage for this deposit is https://sul-purl-stage.stanford.edu/bc123df4567')
    expect(page).to have_link('https://sul-purl-stage.stanford.edu/bc123df4567', href: 'https://sul-purl-stage.stanford.edu/bc123df4567')
  end
end
