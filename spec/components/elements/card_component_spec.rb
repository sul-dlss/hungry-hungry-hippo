# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::CardComponent, type: :component do
  it 'renders the card' do
    render_inline(described_class.new(classes: 'class1').tap do |component|
      component.with_body(classes: 'class2') { '<p>Body</p>'.html_safe }
    end)

    expect(page).to have_css('div.card.class1 div.card-body.class2 p', text: 'Body')
  end
end
