# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::TitleComponent, type: :component do
  include WorkMappingFixtures

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { new_work_form_fixture }

  it 'renders the pane' do
    render_inline(described_class.new(form:, work_form:))

    expect(page).to have_field('title', with: title_fixture)
    expect(page).to have_field('Contact email (one per box)', with: 'aperson@example.com')
    expect(page).to have_field('works_contact_email', type: 'hidden', with: works_contact_email_fixture)
  end
end
