# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::TabForm::HiddenFieldsFormComponent, type: :component do
  let(:component) { described_class.new(model: WorkForm.new, id: 'tabbed_form', hidden_fields: %i[lock version]) }

  it 'renders a form with the given id and hidden fields' do
    render_inline(component)

    expect(page).to have_css('form#tabbed_form[novalidate]')
    expect(page).to have_css('form#tabbed_form input[type=hidden][name="work[lock]"]', visible: :all)
    expect(page).to have_css('form#tabbed_form input[type=hidden][name="work[version]"]', visible: :all)
  end
end
