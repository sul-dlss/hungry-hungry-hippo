# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  describe 'work type validations' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        work_type:,
        work_subtypes:,
        other_work_subtype:,
        abstract:
      )
    end
    let(:work_type) { '' }
    let(:work_subtypes) { [] }
    let(:other_work_subtype) { '' }
    let(:abstract) { abstract_fixture }

    context 'when saving draft with blank work type' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when depositing with blank work type' do
      it 'is invalid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors[:work_type]).to include("can't be blank")
      end
    end

    context 'when Other work type and blank other work subtype' do
      let(:work_type) { 'Other' }

      it 'is invalid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors[:other_work_subtype]).to include("can't be blank")
      end
    end

    context 'when Other work type and other work subtype' do
      let(:work_type) { 'Other' }
      let(:other_work_subtype) { 'baseball cards' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when Music work type and no work subtypes' do
      let(:work_type) { 'Music' }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:work_subtypes_music]).to include('1 term is the minimum allowed')
      end
    end

    context 'when Music work type and one work subtype' do
      let(:work_type) { 'Music' }
      let(:work_subtypes) { ['Album'] }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when Mixed Materials work type and no work subtypes' do
      let(:work_type) { 'Mixed Materials' }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:work_subtypes_mixed_materials]).to include('2 terms are the minimum allowed')
      end
    end

    context 'when Mixed Materials work type and two work subtypes' do
      let(:work_type) { 'Mixed Materials' }
      let(:work_subtypes) { %w[Animation Article] }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'release date validations' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        release_option:,
        release_date:,
        collection_druid: collection.druid
      )
    end

    let(:release_option) { 'delay' }
    let(:release_date) { '' }

    let(:collection) { create(:collection, :with_druid) }

    context 'when release option is immediate' do
      let(:release_option) { 'immediate' }

      it 'does not validate release date' do
        expect(form).to be_valid
      end
    end

    context 'when release option is delay and release date is blank' do
      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:release_date]).to include("can't be blank")
      end
    end

    context 'when release option is delay and release date is valid' do
      let(:release_date) { 1.day.from_now }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when release option is delay and release date is before today' do
      let(:release_date) { 1.day.ago }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end

    context 'when release option is delay and release date after max release date' do
      let(:release_date) { 2.years.from_now }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end
  end

  describe 'Abstract linefeed normalization' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        abstract:
      )
    end
    let(:abstract) { "This is a test.\n\nThis is a second paragraph." }

    it 'normalizes linefeeds' do
      expect(form).to be_valid
      expect(form.abstract).to eq("This is a test.\r\n\r\nThis is a second paragraph.")
    end
  end
end
