# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emails::Works::DoiComponent, type: :component do
  let(:work_presenter) { instance_double(WorkPresenter, doi_link: '<a href="https://doi.org/test">https://doi.org/test</a>') }

  context 'when the work has a DOI' do
    let(:work) { instance_double(Work, doi_assigned?: true) }

    it 'renders the DOI text' do
      render_inline(described_class.new(work:, work_presenter:))

      expect(page).to have_css('p', text: 'Your work was assigned this DOI: https://doi.org/test')
      expect(page).to have_link('https://doi.org/test', href: 'https://doi.org/test')
    end
  end

  context 'when the work does not have a DOI' do
    let(:work) { instance_double(Work, doi_assigned?: false) }

    it 'does not render the DOI text' do
      render_inline(described_class.new(work:, work_presenter:))

      expect(page).to have_no_css('p')
    end
  end
end
