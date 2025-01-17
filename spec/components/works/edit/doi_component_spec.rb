# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::DoiComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }

  let(:work_form) { WorkForm.new }

  context 'when the DOI is already assigned' do
    let(:work_form) { WorkForm.new(doi_option: 'assigned', druid: druid_fixture) }
    let(:collection) { instance_double(Collection) }

    it 'renders a link to the DOI' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_link("https://doi.org/#{doi_fixture}", href: "https://doi.org/#{doi_fixture}")
    end
  end

  context 'when the collection has yes DOI option' do
    let(:collection) { instance_double(Collection, yes_doi_option?: true) }

    it 'notifies the user' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('A DOI will be assigned.')
      expect(page).to have_field('doi_option', type: 'hidden', with: 'yes')
    end
  end

  context 'when the collection has no DOI option' do
    let(:collection) { instance_double(Collection, yes_doi_option?: false, no_doi_option?: true) }

    it 'notifies the user' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('DOI assignment is turned off')
      expect(page).to have_field('doi_option', type: 'hidden', with: 'no')
    end
  end

  context 'when the DOI is not assigned' do
    let(:collection) { instance_double(Collection, yes_doi_option?: false, no_doi_option?: false) }

    it 'allows the user to select whether to assign a DOI' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('Do you want a DOI assigned to this work?')
      expect(page).to have_field('doi_option', type: 'radio', with: 'yes')
      expect(page).to have_field('doi_option', type: 'radio', with: 'no')
    end
  end
end
