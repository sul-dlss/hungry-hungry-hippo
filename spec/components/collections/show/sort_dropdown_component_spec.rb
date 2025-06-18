# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Show::SortDropdownComponent, type: :component do
  let(:collection) { create(:collection, druid: druid_fixture) }
  let(:component) do
    described_class.new(classes: ['sort-dropdown']).tap do |component|
      component.with_sort_option(label: 'Deposit (ascending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=title%20asc")
      component.with_sort_option(label: 'Deposit (descending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=title%20desc")
      component.with_sort_option(label: 'Owner (ascending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=users.name%20asc")
      component.with_sort_option(label: 'Owner (descending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=users.name%20desc")
      component.with_sort_option(label: 'Status (ascending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=status%20asc")
      component.with_sort_option(label: 'Status (descending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=status%20desc")
      component.with_sort_option(label: 'Date modified (ascending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=works.object_updated_at%20asc")
      component.with_sort_option(label: 'Date modified (descending)',
                                 link: "/collections/#{druid_fixture}/works?sort_by=works.object_updated_at%20desc")
    end
  end

  it 'renders the dropdown' do
    render_inline(component)

    expect(page).to have_button('Sort by')
    expect(page).to have_css('a.dropdown-item', text: 'Deposit (ascending)')
    expect(page).to have_css('a.dropdown-item', text: 'Deposit (descending)')
    expect(page).to have_css('a.dropdown-item', text: 'Owner (ascending)')
    expect(page).to have_css('a.dropdown-item', text: 'Owner (descending)')
    expect(page).to have_css('a.dropdown-item', text: 'Status (ascending)')
    expect(page).to have_css('a.dropdown-item', text: 'Status (descending)')
    expect(page).to have_css('a.dropdown-item', text: 'Date modified (ascending)')
    expect(page).to have_css('a.dropdown-item', text: 'Date modified (descending)')
  end
end
