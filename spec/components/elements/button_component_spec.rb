# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ButtonComponent, type: :component do
  it 'renders the button label' do
    render_inline(described_class.new(label: 'Button label'))
    expect(page).to have_css('.btn', text: 'Button label')
  end

  context 'with a variant' do
    it 'renders the button' do
      render_inline(described_class.new(label: 'Button label', variant: 'danger'))
      expect(page).to have_css('.btn.btn-danger')
    end
  end

  context 'with classes' do
    it 'renders the button' do
      render_inline(described_class.new(label: 'Button label', classes: %w[class1 class2]))
      expect(page).to have_css('.btn.class1.class2')
    end
  end
end
