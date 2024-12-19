# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BreadcrumbNavComponent, type: :component do
  let(:component) { described_class.new(dashboard:) }
  let(:dashboard) { true }

  before do
    component.with_breadcrumb(text: 'Breadcrumb 1', link: '/example', active: false)
    component.with_breadcrumb(text: 'Breadcrumb 2', active: true)
  end

  context 'with dashboard' do
    it 'creates breadcrumb nav with dashboard link' do
      render_inline(component)
      expect(page).to have_css('nav#breadcrumbs')
      expect(page).to have_css('li.breadcrumb-item', count: 3)
      expect(page).to have_link('Dashboard', href: '/')
      expect(page).to have_link('Breadcrumb 1', href: '/example')
      expect(page).to have_css('li.breadcrumb-item.active', text: 'Breadcrumb 2')
    end
  end

  context 'without dashboard' do
    let(:dashboard) { false }

    it 'creates breadcrumb nav without dashboard link' do
      render_inline(component)
      expect(page).to have_css('nav#breadcrumbs')
      expect(page).to have_css('li.breadcrumb-item', count: 2)
      expect(page).to have_no_link('Dashboard')
    end
  end
end
