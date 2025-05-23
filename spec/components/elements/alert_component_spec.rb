# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::AlertComponent, type: :component do
  it 'renders the alert' do
    render_inline(described_class.new(title: 'My title', id: 'my-alert'))
    expect(page).to have_css(".alert.alert-info[role='alert']#my-alert")
    expect(page).to have_css('.fw-semibold', text: 'My title')
    expect(page).to have_css('i.bi-info-circle-fill')
  end

  context 'with a body' do
    it 'renders the alert with a body' do
      render_inline(described_class.new(title: 'My title').with_content('<p>My body</p>'.html_safe))

      expect(page).to have_css('p', text: 'My body')
    end
  end

  context 'with a value' do
    it 'renders the alert with a value' do
      render_inline(described_class.new(title: 'My title', value: 'My value'))

      expect(page).to have_text('My value')
    end
  end

  context 'with a variant' do
    it 'renders the alert' do
      render_inline(described_class.new(title: 'My title', variant: :note))

      expect(page).to have_css(".alert.alert-note[role='alert']")
      expect(page).to have_css('i.bi-exclamation-circle-fill')
    end
  end

  context 'with an unknown variant' do
    it 'raises' do
      expect { render_inline(described_class.new(title: 'My title', variant: :notice)) }.to raise_error(ArgumentError)
    end
  end

  context 'without title, value, or content' do
    it 'does not render' do
      render_inline(described_class.new(title: '').with_content(''))

      expect(page).to have_no_css('.alert')
    end
  end
end
