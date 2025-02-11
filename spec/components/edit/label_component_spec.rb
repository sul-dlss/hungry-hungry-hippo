# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::LabelComponent, type: :component do
  it 'renders the label' do
    render_inline(described_class.new(label_text: 'Label'))

    expect(page).to have_css('label.form-label.fw-bold', text: 'Label')
  end

  context 'with hidden label' do
    it 'renders the label' do
      render_inline(described_class.new(label_text: 'Label', hidden_label: true))

      expect(page).to have_css('label.form-label.fw-bold.visually-hidden', text: 'Label')
    end
  end
end
