# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::HeaderComponent, type: :component do
  let(:title) { 'My Title' }
  let(:status_message) { 'Depositing' }
  let(:edit_path) { '/edit/me' }
  let(:destroy_path) { '/destroy/me' }

  it 'renders the header' do
    render_inline(described_class.new(title:, status_message:, edit_path:, destroy_path:, editable: false,
                                      discardable: false))
    expect(page).to have_css('h1', text: title)
    expect(page).to have_css('.status', text: status_message)
    expect(page).to have_no_link('Edit or deposit')
    expect(page).to have_no_button('Discard draft')
  end

  context 'when editable' do
    it 'renders the edit button' do
      render_inline(described_class.new(title:, status_message:, edit_path:, destroy_path:, editable: true,
                                        discardable: false))
      expect(page).to have_link('Edit or deposit', href: edit_path)
    end
  end

  context 'when discardable' do
    it 'renders the discard button' do
      render_inline(described_class.new(title:, status_message:, edit_path:, destroy_path:, editable: false,
                                        discardable: true))
      expect(page).to have_button('Discard draft')
      expect(page).to have_css('form[action="/destroy/me"]')
      expect(page).to have_field('_method', with: 'delete', type: :hidden)
    end
  end
end
