# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::ExtractedAbstractComponent, type: :component do
  let(:component) { described_class.new(abstract:, form:, doi:) }
  let(:doi) { '10.1234/example.doi' }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, ArticleForm.new, vc_test_view_context, {}) }

  context 'when an extracted abstract is available' do
    let(:abstract) { abstract_fixture }

    it 'renders the extracted abstract' do
      render_inline(component)

      expect(page).to have_field('extracted_abstract', with: abstract_fixture, type: 'hidden')
      expect(page).to have_css('p', text: abstract_fixture)
      expect(page).to have_css('p', text: 'We used AI to retrieve this abstract.')
      expect(page).to have_link('Clear abstract', href: '/abstracts/clear?doi=10.1234%2Fexample.doi')
    end
  end

  context 'when an extracted abstract is not available' do
    let(:abstract) { nil }

    it 'renders a message indicating no abstract is available' do
      render_inline(component)

      expect(page).to have_css('.invalid-feedback', text: 'We were not able to extract your abstract.')
    end
  end
end
