# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::HeaderComponent, type: :component do
  let(:presenter) do
    WorkPresenter.new(work_form:, version_status:, work: nil)
  end
  let(:work_form) { WorkForm.new(druid: druid_fixture, title:) }
  let(:version_status) do
    instance_double(VersionStatus, editable?: editable, discardable?: discardable, status_message:)
  end
  let(:title) { 'My Title' }
  let(:status_message) { 'Depositing' }
  let(:editable) { false }
  let(:discardable) { false }

  it 'renders the header' do
    render_inline(described_class.new(presenter:))
    expect(page).to have_css('h1', text: title)
    expect(page).to have_css('.status', text: status_message)
    expect(page).to have_no_link('Edit or deposit')
    expect(page).to have_no_button('Discard draft')
  end

  context 'when editable' do
    let(:editable) { true }

    it 'renders the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_link('Edit or deposit', href: "/works/#{druid_fixture}/edit")
    end
  end

  context 'when discardable' do
    let(:discardable) { true }

    it 'renders the discard button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_button('Discard draft')
      expect(page).to have_css("form[action=\"/works/#{druid_fixture}\"]")
      expect(page).to have_field('_method', with: 'delete', type: :hidden)
    end
  end
end
