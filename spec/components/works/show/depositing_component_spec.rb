# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::DepositingComponent, type: :component do
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new, version_status:, work: instance_double(Work))
  end

  context 'when first version and accessioning' do
    let(:version_status) { build(:first_accessioning_version_status) }

    it 'renders the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_css('.alert', text: 'You have successfully submitted your work for deposit')
      expect(page).to have_css('#depositing-alert[data-turbo-permanent]')
    end
  end

  context 'when other version and accessioning' do
    let(:version_status) { build(:accessioning_version_status) }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_no_css('.alert')
      expect(page).to have_css('#depositing-alert[data-turbo-permanent]')
    end
  end

  context 'when not accessioning' do
    let(:version_status) { build(:first_draft_version_status) }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_no_css('.alert')
      expect(page).to have_css('#depositing-alert[data-turbo-permanent]')
    end
  end
end
