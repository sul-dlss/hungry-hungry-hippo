# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::SalutationComponent, type: :component do
  let(:user) { instance_double(User, first_name: 'Maxwell') }

  it 'renders the salutation' do
    render_inline(described_class.new(user:))

    expect(page).to have_css('p', text: 'Dear Maxwell,')
  end
end
