# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Edit::WorkflowComponent, type: :component do
  subject(:component) { described_class.new(form:) }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, vc_test_view_context, {}) }
  let(:collection_form) { CollectionForm.new(github_deposit_enabled:) }
  let(:informational_text) do
    'If GitHub Integration Workflow is set to "No", new releases for existing GitHub ' \
      'repositories will continue to be deposited.'
  end

  context 'when github deposit is enabled' do
    let(:github_deposit_enabled) { true }

    it 'displays the informational text about new releases' do
      render_inline(component)
      expect(page).to have_text(informational_text)
    end
  end

  context 'when github deposit is disabled' do
    let(:github_deposit_enabled) { false }

    it 'does not display the informational text about new releases' do
      render_inline(component)
      expect(page).to have_no_text(informational_text)
    end
  end
end
