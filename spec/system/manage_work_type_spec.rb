# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit work type and subtypes for a work' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'without required types' do
    let(:collection) { create(:collection, :with_druid, user:) }

    it 'creates a work' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      find('.nav-link', text: 'Type of deposit').click
      expect(page).to have_text('What type of content are you depositing?')
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

      # Changing work type clears subtypes
      choose('Text')
      check('Article')
      expect(page).to have_field('Article', type: :checkbox)

      check('3D model')

      choose('Data')
      choose('Text')
      expect(page).to have_field('3D model', type: :checkbox)
      expect(page).to have_field('Article', type: :checkbox) { |checkbox| expect(checkbox.checked?).to be false }
      expect(page).to have_field('3D model', type: :checkbox) { |checkbox| expect(checkbox.checked?).to be false }

      # Check validation for music
      choose('Music')
      click_link_or_button('Save as draft')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

      find('.nav-link.is-invalid', text: 'Type of deposit').click
      expect(page).to have_css('.invalid-feedback.is-invalid', text: '1 music term is the minimum allowed')

      # Clicking on another work type hides the error message
      choose('Mixed Materials')
      expect(page).to have_no_css('.invalid-feedback.is-invalid', text: '1 term is the minimum allowed')

      check('Capstone')
      click_link_or_button('Save as draft')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

      find('.nav-link.is-invalid', text: 'Type of deposit').click
      expect(page).to have_css('.invalid-feedback.is-invalid', text: '2 terms are the minimum allowed')
    end
  end

  context 'with required types' do
    let(:collection) { create(:collection, :with_druid, :with_required_types, user:) }

    it 'creates a work' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      find('.nav-link', text: 'Type of deposit').click
      expect(page).to have_text('What type of content are you depositing?')
      expect(page).to have_text('The collection manager has selected "Image" as the type for all deposits.')
      expect(page).to have_no_field('Text', type: :radio)
      expect(page).to have_no_field('Image', type: :radio)
      expect(page).to have_field('work[work_type]', type: :hidden, with: 'Image')
      expect(page).to have_field('CAD', checked: true, disabled: true)
      expect(page).to have_field('Map', checked: true, disabled: true)
      expect(page).to have_field('work[work_subtypes][]', type: :hidden, with: 'CAD')
      expect(page).to have_field('work[work_subtypes][]', type: :hidden, with: 'Map')
    end
  end
end
