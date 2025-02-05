# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BreadcrumbNavComponent, type: :component do
  let(:component) { described_class.new }

  before do
    component.with_breadcrumb(text: 'Breadcrumb 1', link: '/example', active: false)
    component.with_breadcrumb(text: 'Breadcrumb 2', active: true)
  end

  it 'creates breadcrumb nav' do
    render_inline(component)
    expect(page).to have_css('nav#breadcrumbs')
    expect(page).to have_css('li.breadcrumb-item', count: 2)
  end
end
