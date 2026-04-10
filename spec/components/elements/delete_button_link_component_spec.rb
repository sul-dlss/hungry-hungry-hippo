# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::DeleteButtonLinkComponent, type: :component do
  let(:link) { '/test/path' }

  it 'renders the button label' do
    render_inline(described_class.new(link:))

    expect(page).to have_css('a.btn.btn-outline-primary')
    expect(page).to have_link('Clear', href: link)
    expect(page).to have_css('span.visually-hidden', text: 'Clear')
    expect(page).to have_css('i.bi.bi-trash')
  end

  context 'with data' do
    it 'renders the button' do
      render_inline(described_class.new(link:, data: { controller: 'test' }))

      expect(page).to have_css('a[data-controller="test"]')
    end
  end

  context 'with classes' do
    it 'renders the button' do
      render_inline(described_class.new(link:, classes: %w[class1 class2]))

      expect(page).to have_css('a.btn.class1.class2')
    end
  end
end
