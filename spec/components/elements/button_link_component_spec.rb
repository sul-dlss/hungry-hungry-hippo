# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ButtonLinkComponent, type: :component do
  let(:link) { '/path' }

  it 'renders the button link' do
    render_inline(described_class.new(link:, label: 'Button link'))
    expect(page).to have_css("a.btn.btn-primary[href='#{link}']", text: 'Button link')
  end

  context 'with a label content' do
    it 'renders the button link' do
      render_inline(described_class.new(link: link).with_content('Button link'))
      expect(page).to have_css('a', text: 'Button link')
    end
  end

  context 'with a variant' do
    it 'renders the button link' do
      render_inline(described_class.new(link:, variant: 'danger'))
      expect(page).to have_css('a.btn.btn-danger')
    end
  end

  context 'with classes' do
    it 'renders the button link' do
      render_inline(described_class.new(link:, classes: %w[class1 class2]))
      expect(page).to have_css('a.btn.btn-primary.class1.class2')
    end
  end
end
