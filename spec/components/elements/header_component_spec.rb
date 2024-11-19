# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::HeaderComponent, type: :component do
  it 'renders an h1 header with provided class' do
    render_inline(described_class.new('h1', classes: %w[mb-4], value: 'Hello World!'))
    expect(page).to have_css('h1.mb-4')
    expect(page).to have_text('Hello World!')
  end

  context 'with an unknown variant' do
    it 'raises' do
      expect { render_inline(described_class.new('h10', value: 'Hello World!')) }.to raise_error(ArgumentError)
    end
  end
end
