# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkPresenter do
  describe '.doi_link' do
    subject(:doi_link) { described_class.new(version_status:, work_form:, work: instance_double(Work)).doi_link }

    let(:work_form) { WorkForm.new(druid:) }
    let(:druid) { druid_fixture }
    let(:version_status) { nil }

    let(:doi) { 'https://doi.org/10.80343/bc123df4567' }
    let(:link) { '<a href="https://doi.org/10.80343/bc123df4567">https://doi.org/10.80343/bc123df4567</a>' }

    context 'when no druid' do
      let(:druid) { nil }

      it { is_expected.to be_nil }
    end

    context 'when NilStatus' do
      let(:version_status) { VersionStatus::NilStatus.new }

      it { is_expected.to eq doi }
    end

    context 'when first draft and open' do
      let(:version_status) { build(:first_draft_version_status) }

      it { is_expected.to eq doi }
    end

    context 'when first draft and accessioning' do
      let(:version_status) { build(:first_accessioning_version_status) }

      it { is_expected.to eq doi }
    end

    context 'when first draft and accessioned' do
      let(:version_status) { build(:first_version_status) }

      it { is_expected.to eq link }
    end

    context 'when not first draft' do
      let(:version_status) { build(:version_status) }

      it { is_expected.to eq link }
    end
  end

  describe '.purl_link' do
    subject(:purl_link) { described_class.new(version_status:, work_form:, work: instance_double(Work)).purl_link }

    let(:work_form) { WorkForm.new(druid:) }
    let(:druid) { druid_fixture }
    let(:version_status) { nil }

    let(:purl) { 'https://sul-purl-stage.stanford.edu/bc123df4567' }
    let(:link) { '<a href="https://sul-purl-stage.stanford.edu/bc123df4567">https://sul-purl-stage.stanford.edu/bc123df4567</a>' }

    context 'when no druid' do
      let(:druid) { nil }

      it { is_expected.to be_nil }
    end

    context 'when NilStatus' do
      let(:version_status) { VersionStatus::NilStatus.new }

      it { is_expected.to eq purl }
    end

    context 'when first draft and open' do
      let(:version_status) { build(:first_draft_version_status) }

      it { is_expected.to eq purl }
    end

    context 'when first draft and accessioning' do
      let(:version_status) { build(:first_accessioning_version_status) }

      it { is_expected.to eq purl }
    end

    context 'when first draft and accessioned' do
      let(:version_status) { build(:first_version_status) }

      it { is_expected.to eq link }
    end

    context 'when not first draft' do
      let(:version_status) { build(:version_status) }

      it { is_expected.to eq link }
    end
  end

  describe '.sharing_link' do
    subject(:sharing_link) do
      described_class.new(version_status: VersionStatus::NilStatus.new, work_form:, work:).sharing_link
    end

    let(:work_form) { WorkForm.new(druid:) }
    let(:druid) { druid_fixture }
    let(:work) { instance_double(Work, doi_assigned?: doi_assigned) }

    context 'when DOI assigned' do
      let(:doi_assigned) { true }

      it { is_expected.to eq 'https://doi.org/10.80343/bc123df4567' }
    end

    context 'when DOI not assigned' do
      let(:doi_assigned) { false }

      it { is_expected.to eq 'https://sul-purl-stage.stanford.edu/bc123df4567' }
    end
  end
end
