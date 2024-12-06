# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit work type and subtypes for a work' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }

  before do
    sign_in(user)
  end

  it 'creates a work' do
    visit new_work_path(collection_druid: collection.druid)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_text('What type of content will you deposit?')
    expect(page).to have_field('work[work_type]', type: :radio, count: WorkType.all.count) # rubocop:disable Rails/RedundantActiveRecordAllMethod

    expect(page).to have_no_field('work[work_subtypes][]', type: :checkbox)

    # Text
    choose('Text')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('Article', type: :checkbox)
    expect(page).to have_no_field('3D model', type: :checkbox)

    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)
    # Duplicate subtype is removed from more options
    expect(page).to have_field('Article', type: :checkbox, count: 1)

    # Data
    choose('Data')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('3D model', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('Animation', type: :checkbox)

    # Software / code
    choose('Software/Code')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('Code', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)

    # Image
    choose('Image')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('CAD', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)

    # Sound
    choose('Sound')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('Interview', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)

    # Video
    choose('Video')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('Conference session', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)

    # Music
    choose('Music')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_text('Select at least one term below:')
    expect(page).to have_field('Data', type: :checkbox)
    click_link_or_button('See more options')
    expect(page).to have_field('3D model', type: :checkbox)

    # Mixed material
    choose('Mixed Materials')
    expect(page).to have_text('Which of the following terms further describe your deposit?')
    expect(page).to have_text('Select at least two terms below:')
    expect(page).to have_field('3D model', type: :checkbox)
    expect(page).to have_no_text('See more options')

    # Other
    choose('Other')
    expect(page).to have_no_text('Which of the following terms further describe your deposit?')
    expect(page).to have_field('Specify "Other" type*', type: :text)
    expect(page).to have_no_field('3D model', type: :checkbox)
    expect(page).to have_no_text('See more options')
  end
end
