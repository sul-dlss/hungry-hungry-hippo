# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ButtonFormComponent, type: :component do
  let(:link) { '/path' }

  it 'renders the button form' do
    render_inline(described_class.new(link:, label: 'Button form'))
    form = page.find('form[data-turbo-frame="_top"][method="get"][action="/path"]')
    expect(form).to have_button('Button form', class: 'btn btn-primary', type: 'submit')
  end

  context 'with a label content' do
    it 'renders the button form' do
      render_inline(described_class.new(link: link).with_content('Button form'))
      expect(page).to have_button('Button form')
    end
  end

  context 'with a variant' do
    it 'renders the button form' do
      render_inline(described_class.new(link:, variant: 'danger', label: 'Submit'))
      expect(page).to have_button('Submit', class: 'btn btn-danger')
    end
  end

  context 'with classes' do
    it 'renders the button form' do
      render_inline(described_class.new(link:, classes: %w[class1 class2], label: 'Submit'))
      expect(page).to have_button('Submit', class: 'btn btn-primary class1 class2')
    end
  end

  context 'with a confirm message' do
    it 'renders the button form' do
      render_inline(described_class.new(link: link, confirm: 'Are you sure?', label: 'Submit'))
      expect(page).to have_css('form[data-turbo-confirm="Are you sure?"]')
    end
  end

  context 'with a method' do
    it 'renders the button form' do
      render_inline(described_class.new(link: link, method: :post, label: 'Submit'))
      expect(page).to have_css('form[method="post"]')
    end
  end
end
