# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::OptionsComponent, type: :component do
  let(:work_presenter) do
    instance_double(WorkPresenter, license_label: 'CC-BY-4.0 Attribution International',
                                   access_label: 'Stanford Community', release_date_label: 'June 10, 2027')
  end

  it 'renders the options text' do
    render_inline(described_class.new(work_presenter:))

    expect(page).to have_text('You selected the following options:')
    expect(page).to have_text('License: CC-BY-4.0 Attribution International')
    expect(page).to have_text('Access level: Stanford Community')
    expect(page).to have_text('Release: June 10, 2027')
  end
end
