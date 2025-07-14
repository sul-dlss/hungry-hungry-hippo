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
        abstract:,
        whats_changing:
      )
    end
    let(:work_type) { '' }
    let(:work_subtypes) { [] }
    let(:other_work_subtype) { '' }
    let(:abstract) { abstract_fixture }
    let(:whats_changing) { 'Initial version' }

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
        expect(form.errors[:work_subtypes_music]).to include('1 music term is the minimum allowed')
      end
    end

    context 'when Music work type and non music work subtypes' do
      let(:work_type) { 'Music' }
      let(:work_subtypes) { ['Newspaper'] }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:work_subtypes_music]).to include('1 music term is the minimum allowed')
      end
    end

    context 'when Music work type and one work subtype' do
      let(:work_type) { 'Music' }
      let(:work_subtypes) { ['Sound'] }

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

    context 'when whats changing is blank' do
      let(:whats_changing) { '' }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:whats_changing]).to include("can't be blank")
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
        max_release_date:,
        whats_changing: 'Initial version'
      )
    end

    let(:release_option) { 'delay' }
    let(:release_date) { '' }
    let(:max_release_date) { 1.year.from_now }

    context 'when release option is immediate' do
      let(:release_option) { 'immediate' }

      it 'does not validate release date' do
        expect(form).to be_valid
      end
    end

    context 'when release option is delay and release date is blank' do
      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:release_date]).to include('must be today or later')
        expect(form.errors[:release_date])
          .to include("must be on or before #{(Time.zone.today + 1.year).strftime('%m/%d/%Y')}")
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
        create_date_type: 'range',
        create_date_range_from_attributes: creation_date_range_from,
        create_date_range_to_attributes: creation_date_range_to,
        whats_changing: 'Initial version'
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

  describe 'keyword validation' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        abstract: abstract_fixture,
        license: license_fixture,
        work_type: work_type_fixture,
        keywords_attributes:,
        whats_changing: 'Initial version'
      )
    end

    context 'when keywords are provided' do
      let(:keywords_attributes) do
        [
          {
            'text' => 'Biology',
            'uri' => 'http://id.worldcat.org/fast/832383/',
            'cocina_type' => 'topic'
          },
          {
            'text' => 'MyBespokeKeyword',
            'uri' => nil,
            'cocina_type' => nil
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'is valid when depositing' do
        expect(form.valid?(:deposit)).to be true
      end
    end

    context 'when keywords with a blank are provided' do
      let(:keywords_attributes) do
        [
          {
            'text' => 'Biology',
            'uri' => 'http://id.worldcat.org/fast/832383/',
            'cocina_type' => 'topic'
          },
          {
            'text' => '',
            'uri' => nil,
            'cocina_type' => nil
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'is valid when depositing' do
        expect(form.valid?(:deposit)).to be true
      end
    end

    context 'when keywords with only a blank are provided' do
      let(:keywords_attributes) do
        [
          {
            'text' => '',
            'uri' => nil,
            'cocina_type' => nil
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'is invalid when depositing' do
        expect(form.valid?(:deposit)).to be false
        expect(form.keywords.first.errors[:text]).to include('can\'t be blank')
      end
    end

    context 'when keywords with multiple blank provided' do
      let(:keywords_attributes) do
        [
          {
            'text' => '',
            'uri' => nil,
            'cocina_type' => nil
          },
          {
            'text' => '',
            'uri' => nil,
            'cocina_type' => nil
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'is invalid when depositing' do
        expect(form.valid?(:deposit)).to be false
        expect(form.keywords.first.errors[:text]).to include('can\'t be blank')
      end
    end
  end

  describe 'contributors validation' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes:,
        abstract: abstract_fixture,
        license: license_fixture,
        work_type: work_type_fixture,
        whats_changing: 'Initial version'
      )
    end

    context 'when a contributor is provided' do
      let(:contributors_attributes) { contributors_fixture }

      it 'is valid' do
        expect(form.valid?(:deposit)).to be false
      end
    end

    context 'when no contributor is provided' do
      let(:contributors_attributes) do
        [
          {
            'role_type' => 'person',
            'person_role' => 'author',
            'organization_role' => nil,
            'first_name' => '',
            'last_name' => '',
            'with_orcid' => true,
            'orcid' => '',
            'organization_name' => nil,
            'stanford_degree_granting_institution' => false,
            'suborganization_name' => nil,
            'collection_required' => false
          }
        ]
      end

      context 'when not depositing' do
        it 'is valid' do
          expect(form).to be_valid
        end
      end

      context 'when depositing' do
        it 'is invalid' do
          expect(form.valid?(:deposit)).to be false
          expect(form.errors[:contributors]).to include('must have at least one contributor')
        end
      end
    end
  end

  describe 'contact email validation' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes:,
        works_contact_email:,
        contributors_attributes: contributors_fixture,
        abstract: abstract_fixture,
        license: license_fixture,
        work_type: work_type_fixture,
        whats_changing: 'Initial version'
      )
    end

    let(:works_contact_email) { nil }

    context 'when a contact email is provided' do
      let(:contact_emails_attributes) do
        [
          {
            'email' => 'aperson@example.com'
          },
          {
            'email' => 'anotherperson@example.com'
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when a contact email and a blank is provided' do
      let(:contact_emails_attributes) do
        [
          {
            'email' => 'aperson@example.com'
          },
          {
            'email' => ''
          }
        ]
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when only a blank is provided' do
      let(:contact_emails_attributes) do
        [
          {
            'email' => ''
          }
        ]
      end

      it 'is invalid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.contact_emails.first.errors[:email]).to include('can\'t be blank')
      end
    end

    context 'when only a blank is provided but has a required contact email' do
      let(:contact_emails_attributes) do
        [
          {
            'email' => ''
          }
        ]
      end

      let(:works_contact_email) { 'someone@stanford.edu' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'content file validation' do
    let(:form) do
      described_class.new(
        title: title_fixture,
        contact_emails_attributes: contact_emails_fixture,
        contributors_attributes: contributors_fixture,
        abstract: abstract_fixture,
        license: license_fixture,
        work_type: work_type_fixture,
        content_id: content.id,
        keywords_attributes: keywords_fixture,
        whats_changing: 'Initial version'
      )
    end

    context 'when no content files' do
      let(:content) { create(:content) }

      it 'is invalid' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors[:content]).to include('must have at least one file')
      end
    end

    context 'when content files' do
      let(:content) { create(:content, :with_content_files) }

      it 'is valid' do
        expect(form.valid?(:deposit)).to be true
      end
    end

    context 'when too many content files' do
      let(:content) { create(:content, :with_content_files) }

      before do
        allow(Settings.file_upload).to receive(:max_files).and_return(1)
      end

      it 'is invalid' do
        expect(form.valid?).to be false
        expect(form.errors[:content]).to include('too many files (maximum is 1)')
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
        custom_rights_statement:,
        whats_changing: 'Initial version'
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
end
