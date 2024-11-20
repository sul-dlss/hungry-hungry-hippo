# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::HeaderComponent, type: :component do
  it 'renders an h1 header with provided class' do
    render_inline(described_class.new(level: :h1, text: 'Hello World!', classes: %w[mb-4]))
    expect(page).to have_css('h1.mb-4')
    expect(page).to have_text('Hello World!')
  end

  context 'with a known variant symbol' do
    it 'adds the variant class' do
      render_inline(described_class.new(level: :h1, text: 'Hello World!', variant: :h2, classes: %w[mb-4]))
      expect(page).to have_css('h1.h2')
      expect(page).to have_css('h1.mb-4')
      expect(page).to have_text('Hello World!')
    end
  end

  context 'with a known variant string' do
    it 'adds the variant class' do
      render_inline(described_class.new(level: :h1, text: 'Hello World!', variant: 'h3', classes: %w[mb-4]))
      expect(page).to have_css('h1.h3')
      expect(page).to have_css('h1.mb-4')
      expect(page).to have_text('Hello World!')
    end
  end

  context 'with an unknown variant' do
    it 'raises' do
      expect do
        render_inline(described_class.new(level: :h10, text: 'Hello World!', variant: :h10))
      end.to raise_error(ArgumentError)
    end
  end
end
