# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ProgressBarComponent, type: :component do
  it 'renders the progress bar' do
    render_inline(described_class.new(label: 'test'))
    expect(page).to have_css("div.progress[role='progressbar'][aria-label='test'] " \
                             'div.progress-bar.progress-bar-striped')
    expect(page.find('div.progress-bar')[:style]).to eq('width: 0%;')
  end

  context 'with a variant' do
    it 'renders the progress bar with the variant' do
      render_inline(described_class.new(label: 'test', variant: 'danger'))
      expect(page).to have_css('div.progress-bar.bg-danger')
    end
  end

  context 'with custom classes' do
    it 'renders the progress bar with the custom classes' do
      render_inline(described_class.new(label: 'test', classes: %w[class1 class2]))
      expect(page).to have_css('div.class1.class2')
    end
  end

  context 'with a percent' do
    it 'renders the progress bar with the percent' do
      render_inline(described_class.new(label: 'test', percent: 50))

      expect(page).to have_css("div.progress[aria-valuenow='50']")
      expect(page.find('div.progress-bar')[:style]).to eq('width: 50%;')
    end
  end

  context 'with data' do
    it 'renders the progress bar with the percent' do
      render_inline(described_class.new(label: 'test', data: { test: 'value' }))

      expect(page).to have_css("div.progress[data-test='value']")
    end
  end
end
