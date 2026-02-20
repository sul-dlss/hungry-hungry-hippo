# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Edit::PaneComponent, type: :component do
  let(:component) do
    described_class.new(tab_name: :test_pane, label: 'Test Pane', active_tab_name:, collection_presenter:,
                        previous_tab_btn:, next_tab_btn:, mark_required:)
  end
  let(:active_tab_name) { :test_pane }
  let(:collection_presenter) { nil }
  let(:previous_tab_btn) { true }
  let(:next_tab_btn) { true }
  let(:mark_required) { false }

  context 'when no deposit button provided' do
    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_css('.h4', text: 'Test Pane (optional)')
      expect(tab_pane).to have_css('div', text: 'Test Pane Content')
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_link('Cancel')
      expect(tab_pane).to have_no_button('Deposit')
    end
  end

  context 'when deposit button provided' do
    it 'renders the pane' do
      render_inline(component.tap do |component|
        component.with_deposit_button { '<button>Deposit</button>'.html_safe }
      end) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_link('Cancel')
      expect(tab_pane).to have_button('Deposit')
    end
  end

  context 'when no previous tab button' do
    let(:previous_tab_btn) { false }

    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_no_button('Previous')
    end
  end

  context 'when no next tab button' do
    let(:next_tab_btn) { false }

    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_no_button('Next')
      expect(tab_pane).to have_button('Previous')
    end
  end

  context 'when this is active pane' do
    it 'renders the pane with active class' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      expect(page).to have_css('div.tab-pane.active')
    end
  end

  context 'when this is not active pane' do
    let(:active_tab_name) { :other_pane }

    it 'renders the pane without active class' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      expect(page).to have_css('div.tab-pane:not(.active)')
    end
  end

  context 'when not persisted' do
    it 'renders the pane with cancel button to dashboard' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_link('Cancel', href: '/dashboard')
    end
  end

  context 'when persisted' do
    let(:collection_presenter) do
      CollectionPresenter.new(collection: nil, collection_form: CollectionForm.new(druid: collection_druid_fixture),
                              version_status: nil)
    end

    it 'renders the pane with cancel button to show' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_link('Cancel', href: "/collections/#{collection_druid_fixture}")
    end
  end

  context 'when marking required' do
    let(:mark_required) { true }

    it 'renders the pane with required label' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_css('.h4', text: 'Test Pane', exact_text: true)
    end
  end
end
