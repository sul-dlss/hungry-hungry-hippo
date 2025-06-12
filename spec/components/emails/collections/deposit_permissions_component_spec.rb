# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Collections::DepositPermissionsComponent, type: :component do
  let(:collection) { create(:collection) }

  it 'renders the deposit permissions text' do
    render_inline(described_class.new(collection:))

    expect(page).to have_css('p', text: 'You now also have permission to deposit items into the ' \
                                        "#{collection.title} collection.")
  end
end
