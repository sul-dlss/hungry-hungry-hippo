# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::VersionIdentificationComponent, type: :component do
  let(:component) { described_class.new(form:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, ArticleWorkForm.new, vc_test_view_context, {}) }

  it 'renders the component with the correct options' do
    render_inline(component)

    expect(page).to have_select(with_required_field_mark('Which version are you depositing?'),
                                options: ['Select...'] + BaseWorkForm::ARTICLE_VERSION_IDENTIFICATION_OPTIONS,
                                selected: nil)
  end
end
