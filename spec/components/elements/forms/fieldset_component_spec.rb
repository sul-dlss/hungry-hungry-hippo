# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::FieldsetComponent, type: :component do
  it 'renders the fieldset with a label' do
    render_inline(described_class.new(
                    label: 'My Fieldset', classes: 'class1', legend_classes: 'class2', label_classes: 'class3',
                    data: { my_data: true }
                  )) { '<p>Fieldset content</p>'.html_safe }

    expect(page).to have_css('fieldset.form-fieldset.class1[data-my-data="true"] legend.class2 label.form-label.fw-bold.class3', # rubocop:disable Layout/LineLength
                             text: 'My Fieldset')
    expect(page).to have_css('fieldset p', text: 'Fieldset content')
  end

  context 'when the label is hidden' do
    it 'renders the fieldset with a hidden label' do
      render_inline(described_class.new(label: 'My Fieldset', hidden_label: true))

      expect(page).to have_css('fieldset.form-fieldset label.visually-hidden', text: 'My Fieldset')
    end
  end

  context 'when the fieldset has a help_link' do
    it 'renders the fieldset with a help_link' do
      render_inline(
        described_class.new(label: 'My Fieldset').tap do |component|
          component.with_help_link { '<a>Help</a>'.html_safe }
        end
      )

      expect(page).to have_css('a', text: 'Help')
    end
  end
end
