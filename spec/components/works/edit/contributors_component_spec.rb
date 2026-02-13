# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::ContributorsComponent, type: :component do
  include WorkMappingFixtures

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { new_work_form_fixture }

  it 'renders the pane' do
    render_inline(described_class.new(form:))

    expect(page).to have_field('[contributors_attributes][0][first_name]', with: 'Jane')
    expect(page).to have_field('[contributors_attributes][0][last_name]', with: 'Stanford')
  end
end
