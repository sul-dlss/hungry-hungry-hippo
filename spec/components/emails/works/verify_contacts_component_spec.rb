# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::VerifyContactsComponent, type: :component do
  it 'renders the verify contacts text' do
    render_inline(described_class.new)

    expect(page).to have_css('p', text: 'Please check the contact emails information on this ' \
                                        'item and if it is no longer current, update this field ' \
                                        'by clicking on the blue pencil icon next to the header ' \
                                        '"Title and contact."')
  end
end
