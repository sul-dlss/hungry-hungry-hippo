# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::RelatedContentShowComponent, type: :component do
  let(:related_work) { RelatedWorkForm.new(citation:, identifier:, relationship:) }
  let(:related_works) { [related_work] }
  let(:citation) { 'A related work' }
  let(:identifier) { 'https://example.org/related' }
  let(:relationship) { 'isCitedBy' }
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new(related_works:),
                      version_status: instance_double(VersionStatus, editable?: false),
                      work: instance_double(Work))
  end

  context 'with a related work that has a URL' do
    it 'renders the related work with a link' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_content('Related published work')
      expect(page).to have_link('https://example.org/related', href: 'https://example.org/related')
      expect(page).to have_content('Is Cited By')
    end
  end

  context 'with a related work that is not a URL' do
    let(:identifier) { nil }

    it 'renders the related work with a link' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_content('Related published work')
      expect(page).to have_no_link('https://example.org/related', href: 'https://example.org/related')
      expect(page).to have_content('A related work')
      expect(page).to have_content('Is Cited By')
    end
  end

  context 'with no related works' do
    let(:related_works) { [] }

    it 'renders the related content section with a blank row' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_content('Related published work')
    end
  end
end
