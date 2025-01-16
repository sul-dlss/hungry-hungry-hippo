# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::AccessSettingsComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new(access: 'stanford') }
  let(:collection) do
    instance_double(Collection, depositor_selects_access?: depositor_select_access,
                                immediate_release_option?: immediate_release,
                                max_release_date:)
  end

  let(:immediate_release) { true }
  let(:depositor_select_access) { false }
  let(:max_release_date) { Time.zone.today + 1.year }

  context 'when the depositor selects access' do
    let(:depositor_select_access) { true }

    it 'renders the select' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_select('Who can download the files?', options: ['Stanford Community', 'Everyone'])
    end
  end

  context 'when the collection specifies access' do
    it 'states the access and renders a hidden field' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('The files in your deposit will be downloadable by the Stanford Community.')
      expect(page).to have_field('access', type: 'hidden', with: 'stanford')
    end
  end

  context 'when the collection specifies immediate release' do
    it 'states the immediate release and renders a hidden field' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('Your files with be available shortly after you deposit this item.')
      expect(page).to have_field('release_option', type: 'hidden', with: 'immediate')
    end
  end

  context 'when the depositor selects release date' do
    let(:immediate_release) { false }

    it 'renders the radio buttons and datepicker' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('Select when the files in your deposit will be downloadable')
      expect(page).to have_field('release_option', type: 'radio', with: 'immediate', checked: true)
      expect(page).to have_field('release_option', type: 'radio', with: 'delay')
      expect(page).to have_css("div[data-controller='datepicker'][data-datepicker-min-value='#{Time.zone.today.iso8601}']") # rubocop:disable Metrics/LineLength
      expect(page).to have_css("div[data-controller='datepicker'][data-datepicker-max-value='#{max_release_date.iso8601}']") # rubocop:disable Metrics/LineLength
      expect(page).to have_text("Date must be before #{max_release_date.strftime('%B %d, %Y')}")
    end
  end
end
