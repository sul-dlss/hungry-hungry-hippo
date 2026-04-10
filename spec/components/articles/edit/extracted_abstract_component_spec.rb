# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::ExtractedAbstractComponent, type: :component do
  let(:component) { described_class.new(abstract:, form:, doi:, content_id: 12) }
  let(:doi) { '10.1234/example.doi' }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, ArticleForm.new, vc_test_view_context, {}) }

  let(:abstract) { abstract_fixture }

  it 'renders the extracted abstract' do
    render_inline(component)

    expect(page).to have_field('extracted_abstract', with: abstract_fixture)
    expect(page).to have_css('p', text: 'We used AI to try to retrieve the exact abstract')
    expect(page).to have_link('Clear abstract')
  end
end
