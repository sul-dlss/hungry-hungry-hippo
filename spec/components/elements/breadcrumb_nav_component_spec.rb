# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BreadcrumbNavComponent, type: :component do
  let(:component) { described_class.new }

  let(:title) do
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ullamcorp'
  end

  let(:collection) do
    'Sed molestie elit sit amet malesuada tempus orn'
  end

  before do
    component.with_breadcrumb(text: 'Breadcrumb 1', link: '/example', active: false)
    component.with_collection_breadcrumb(text: "#{collection} and more text")
    component.with_title_breadcrumb(text: "#{title} and more text")
    component.with_breadcrumb(text: 'Breadcrumb 2', active: true)
  end

  it 'creates breadcrumb nav' do
    render_inline(component)
    expect(page).to have_css('nav#breadcrumbs')
    expect(page).to have_css('li.breadcrumb-item', count: 4)
    expect(page).to have_css('li.breadcrumb-item', text: "#{collection}...")
    expect(page).to have_css('li.breadcrumb-item', text: "#{title}...")
    expect(page).to have_css('li.breadcrumb-item.active', text: 'Breadcrumb 2')
  end
end
