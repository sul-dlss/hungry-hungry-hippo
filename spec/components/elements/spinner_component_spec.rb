# frozen_string_literal: true

require 'rails_helper'

# frozen_string_literal: true

RSpec.describe Elements::SpinnerComponent, type: :component do
  it 'renders the spinner' do
    render_inline(described_class.new)
    expect(page).to have_css(".spinner-border[role='status']")
    expect(page).to have_text('Loading...')
  end

  context 'with a custom, hidden message' do
    it 'does not render the message' do
      render_inline(described_class.new(message: 'Hidden message...', hide_message: true))
      expect(page).to have_css('.visually-hidden', text: 'Hidden message...')
    end
  end

  context 'with a variant' do
    it 'renders the spinner with the variant' do
      render_inline(described_class.new(variant: 'danger'))
      expect(page).to have_css('.spinner-border.text-danger')
    end
  end

  context 'with custom classes' do
    it 'renders the spinner with the custom classes' do
      render_inline(described_class.new(classes: %w[class1 class2]))
      expect(page).to have_css('div.class1.class2')
    end
  end
end