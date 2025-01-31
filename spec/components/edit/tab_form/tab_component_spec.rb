# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::TabForm::TabComponent, type: :component do
  it 'renders a tab' do
    render_inline(described_class.new(label: 'Tab 1', tab_name: :tab_one))

    expect(page).to have_css('div#tab_one-tab', text: 'Tab 1')
  end
end
