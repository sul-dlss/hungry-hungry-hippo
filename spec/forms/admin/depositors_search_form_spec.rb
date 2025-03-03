# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DepositorsSearchForm do
  subject(:form) { described_class.new(druids:) }

  let(:druids) { works.pluck(:druid).join(' ') }
  let(:works) { create_list(:work, 2, :with_druid) }

  describe 'validation' do
    context 'with all work druids' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'with at least one non-work druid' do
      let(:druids) { works.pluck(:druid).append(missing_druid).join(' ') }
      let(:missing_druid) { 'druid:foobar' }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:druids]).to eq(["work not found: #{missing_druid}"])
      end
    end

    context 'with values lacking the druid prefix' do
      before { form.valid? }

      let(:druids) { 'rp380fj3724 wq014dg6733' }

      it 'prepends the prefix before validation' do
        expect(form.druids).to eq('druid:rp380fj3724 druid:wq014dg6733')
      end
    end

    context 'with duplicate values' do
      before { form.valid? }

      let(:druids) { 'rp380fj3724 wq014dg6733 rp380fj3724 wq014dg6733 rp380fj3724 wq014dg6733' }

      it 'deduplicates the list before validation' do
        expect(form.druids).to eq('druid:rp380fj3724 druid:wq014dg6733')
      end
    end
  end

  describe '#druid_list' do
    it 'returns the druids as an array' do
      expect(form.druid_list).to be_an(Array)
    end
  end
end
