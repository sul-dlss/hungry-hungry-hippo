# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  include WorkMappingFixtures

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

  describe 'create date range validation' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        # collection_druid: collection.druid,
        create_date_type: 'range',
        create_date_range_from_attributes: creation_date_range_from,
        create_date_range_to_attributes: creation_date_range_to
      )
    end

    let(:creation_date_range_to) do
      {
        year: 2022,
        month: 4,
        day: nil,
        approximate: true
      }
    end

    let(:creation_date_range_from) do
      {
        year: 2021,
        month: 3,
        day: 7,
        approximate: false
      }
    end

    context 'when create date range is complete and in sequence' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when from date is after to date' do
      let(:creation_date_range_to) do
        {
          year: 2021
        }
      end

      let(:creation_date_range_from) do
        {
          year: 2022
        }
      end

      it 'is not valid' do
        expect(form).not_to be_valid

        expect(form.errors[:create_date_range_from]).to eq(['must be before end date'])
      end
    end

    context 'when from date is blank' do
      let(:creation_date_range_from) do
        {}
      end

      it 'is not valid' do
        expect(form).not_to be_valid

        expect(form.errors[:create_date_range_from]).to eq(['must have both a start and end date'])
      end
    end

    context 'when to date is blank' do
      let(:creation_date_range_to) do
        {}
      end

      it 'is not valid' do
        expect(form).not_to be_valid

        expect(form.errors[:create_date_range_from]).to eq(['must have both a start and end date'])
      end
    end
  end

  describe 'Abstract linefeed normalization' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        abstract:,
        custom_rights_statement:
      )
    end
    let(:abstract) { "This is a test.\n\nThis is a second paragraph." }
    let(:custom_rights_statement) { "This is a test.\n\nThis is a second paragraph." }

    it 'normalizes linefeeds' do
      expect(form).to be_valid
      expect(form.abstract).to eq("This is a test.\r\n\r\nThis is a second paragraph.")
      expect(form.custom_rights_statement).to eq("This is a test.\r\n\r\nThis is a second paragraph.")
    end
  end

  describe 'Whats changing validation' do
    before do
      create(:collection, druid: collection_druid_fixture)
    end

    context 'when first draft and depositing' do
      let(:work_form) do
        new_work_form_fixture.tap do |form|
          form.release_date = 1.day.from_now
        end
      end

      it 'is valid' do
        expect(work_form.whats_changing).to be_nil
        expect(work_form).to be_valid
      end
    end

    context 'when not first draft and depositing' do
      let(:work_form) do
        work_form_fixture.tap do |form|
          form.release_date = 1.day.from_now
          form.whats_changing = nil
        end
      end

      it 'is invalid' do
        expect(work_form.valid?(:deposit)).to be false
        expect(work_form.errors[:whats_changing]).to include("can't be blank")
      end
    end

    context 'when not first draft and depositing and whats changing is provided' do
      let(:work_form) do
        work_form_fixture.tap do |form|
          form.release_date = 1.day.from_now
        end
      end

      it 'is valid' do
        expect(work_form.valid?(:deposit)).to be true
      end
    end

    context 'when not first draft and saving draft' do
      let(:work_form) do
        work_form_fixture.tap do |form|
          form.release_date = 1.day.from_now
          form.whats_changing = nil
        end
      end

      it 'is invalid' do
        expect(work_form).to be_valid
      end
    end
  end
end
