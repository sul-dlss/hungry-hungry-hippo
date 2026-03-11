# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Edit::WorkflowComponent, type: :component do
  subject(:component) { described_class.new(form:) }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, vc_test_view_context, {}) }
  let(:collection_form) { CollectionForm.new }
  let(:informational_text) do
    'Once a Github repository is set up for automatic depositing, new releases will continue to be deposited ' \
      'unless turned off in the edit form for the individual item even if this workflow is set to "No".'
  end

  it 'displays the informational text about new releases' do
    render_inline(component)
    expect(page).to have_text(informational_text)
  end
end
