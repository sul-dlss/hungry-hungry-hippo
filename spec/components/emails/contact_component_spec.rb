# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::ContactComponent, type: :component do
  it 'renders the contact information' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'If you have any questions, contact the SDR team at: http://test.host/#help')
    expect(page).to have_link('http://test.host/#help', href: 'http://test.host/#help')
  end
end
