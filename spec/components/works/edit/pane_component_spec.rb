# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::PaneComponent, type: :component do
  let(:component) do
    described_class.new(tab_name: :test_pane, label: 'Test Pane', form_id: 'new_work',
                        discard_draft_form_id: 'discard_draft_form', work_presenter:, active_tab_name:,
                        previous_tab_btn:, next_tab_btn:)
  end
  let(:work_presenter) { nil }
  let(:active_tab_name) { :test_pane }
  let(:previous_tab_btn) { true }
  let(:next_tab_btn) { true }
  let(:user) { create(:user) }

  before do
    Current.user = user
    Current.groups = []
  end

  context 'when no work presenter (new work)' do
    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_css('.h4', text: 'Test Pane')
      expect(tab_pane).to have_css('div', text: 'Test Pane Content')
      expect(tab_pane).to have_button('Save as draft') { |btn| expect(btn[:form]).to eq('new_work') }
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_button('Previous')
      expect(tab_pane).to have_link('Cancel', href: '/dashboard')
      expect(tab_pane).to have_no_button('Discard draft')
    end
  end

  context 'when work presenter (existing work, first_draft)' do
    let(:version_status) { build(:first_draft_version_status) }
    let(:work) { create(:work, :with_druid, user:) }
    let(:work_presenter) do
      WorkPresenter.new(work:, work_form: WorkForm.new(druid: work.druid), version_status:)
    end

    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_button('Save as draft') { |btn| expect(btn[:form]).to eq('new_work') }
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_button('Previous')
      expect(tab_pane).to have_button('Discard draft') { |btn| expect(btn[:form]).to eq('discard_draft_form') }
      expect(tab_pane).to have_link('Cancel', href: "/works/#{work.druid}")
    end
  end

  context 'when work presenter (existing work, not first_draft)' do
    let(:version_status) { build(:version_status) }
    let(:work) { create(:work, :with_druid, user:) }
    let(:work_presenter) do
      WorkPresenter.new(work:, work_form: WorkForm.new(druid: work.druid), version_status:)
    end

    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_button('Save as draft') { |btn| expect(btn[:form]).to eq('new_work') }
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_button('Previous')
      expect(tab_pane).to have_no_button('Discard draft')
      expect(tab_pane).to have_link('Cancel', href: "/works/#{work.druid}")
    end
  end

  context 'when deposit button provided' do
    it 'renders the pane' do
      render_inline(component.tap do |component|
        component.with_deposit_button { '<button>Deposit</button>'.html_safe }
      end) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_button('Save as draft') { |btn| expect(btn[:form]).to eq('new_work') }
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_link('Cancel')
      expect(tab_pane).to have_no_button('Discard draft')
      expect(tab_pane).to have_button('Deposit')
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
end
