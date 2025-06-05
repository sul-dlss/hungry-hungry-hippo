# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RecentActivityFormComponent, type: :component do
  let(:form) { Admin::RecentActivityForm.new }
  let(:type) { 'works' }

  it 'renders the recent activity form with select field for days limit' do
    render_inline(described_class.new(form:, type:))

    expect(page).to have_css('label.form-label.visually-hidden', text: 'Days limit')
    expect(page).to have_select('admin_recent_activity_days_limit')
    expect(page).to have_css('option', text: '1 day')
    expect(page).to have_css('option', text: '7 days')
    expect(page).to have_css('option', text: '14 days')
    expect(page).to have_css('option', text: '30 days')
  end
end
