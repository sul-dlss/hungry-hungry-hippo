# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a work' do
  let(:druid) { 'druid:bc123df4567' }

  let(:cocina_object) do
    build(:dro, title: 'My Work', id: druid)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    create(:work, druid: druid)

    sign_in(create(:user))
  end

  it 'edits a work' do
    visit edit_work_path(druid)

    expect(page).to have_css('h1', text: 'My Work')

    expect(page).to have_field('Title of deposit', with: 'My Work')
  end
end
