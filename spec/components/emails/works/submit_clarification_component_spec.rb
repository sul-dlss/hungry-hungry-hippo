# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::SubmitClarificationComponent, type: :component do
  it 'renders the clarificatory text' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'If you did not recently submit')
  end
end
