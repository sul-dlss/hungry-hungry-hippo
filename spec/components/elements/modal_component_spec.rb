# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ModalComponent, type: :component do
  let(:component) do
    described_class.new(id: 'test', size:).tap do |component|
      component.with_header { '<h1>Header</h1>'.html_safe }
      component.with_body { '<p>Body</p>'.html_safe }
      component.with_footer { '<button>Footer</button>'.html_safe }
    end
  end

  let(:size) { :lg }

  it 'renders the modal' do
    render_inline(component)
    expect(page).to have_css('div.modal.modal-lg div.modal-dialog div.modal-content div.modal-header h1',
                             text: 'Header')
    expect(page).to have_css('div.modal-header button.btn-close')
    expect(page).to have_css('div.modal.modal-lg div.modal-dialog div.modal-content div.modal-body p',
                             text: 'Body')
    expect(page).to have_css('div.modal.modal-lg div.modal-dialog div.modal-content div.modal-footer button',
                             text: 'Footer')
  end

  context 'with nil size' do
    let(:size) { nil }

    it 'renders the modal without a size' do
      render_inline(component)
      expect(page).to have_css('div.modal')
      expect(page).to have_no_css('div.modal.modal-lg')
    end
  end
end
