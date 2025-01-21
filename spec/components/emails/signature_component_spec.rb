# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::SignatureComponent, type: :component do
  it 'renders the signature' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'The Stanford Digital Repository Team')
  end
end
