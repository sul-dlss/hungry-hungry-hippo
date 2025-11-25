# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkFormSerializer do
  let(:druid) { 'druid:bc123df4567' }
  let(:serialized_form) do
    {
      '_aj_serialized' => 'WorkFormSerializer',
      'title' => title_fixture,
      'druid' => druid,
      'collection_druid' => collection_druid_fixture,
      'version' => 1,
      'lock' => nil,
      'abstract' => abstract_fixture,
      'contributors_attributes' => contributors_fixture,
      'citation' => citation_fixture,
      'related_works_attributes' => related_works_fixture,
      'license' => license_fixture,
      'publication_date_attributes' => publication_date_fixture,
      'contact_emails_attributes' => contact_emails_fixture,
      'keywords_attributes' => keywords_fixture,
      'work_type' => work_type_fixture,
      'work_subtypes' => work_subtypes_fixture,
      'other_work_subtype' => nil,
      'content_id' => 5,
      'access' => 'stanford',
      'release_option' => 'delay',
      'release_date' => release_date_fixture.to_date,
      'custom_rights_statement' => custom_rights_statement_fixture,
      'doi_option' => 'yes',
      'agree_to_terms' => true,
      'create_date_single_attributes' => creation_date_single_fixture,
      'create_date_range_from_attributes' => creation_date_range_from_fixture,
      'create_date_range_to_attributes' => creation_date_range_to_fixture,
      'create_date_type' => 'single',
      'whats_changing' => whats_changing_fixture,
      'works_contact_email' => nil,
      'max_release_date' => nil,
      'creation_date' => creation_date_fixture,
      'deposit_publication_date' => deposit_publication_date_fixture,
      'apo' => 'druid:hv992ry2431',
      'copyright' => copyright_fixture,
      'form_id' => form_id_fixture
    }
  end
  let(:work_form) do
    WorkForm.new(title: title_fixture,
                 druid:,
                 collection_druid: collection_druid_fixture,
                 abstract: abstract_fixture,
                 contributors_attributes: contributors_fixture,
                 citation: citation_fixture,
                 related_works_attributes: related_works_fixture,
                 license: license_fixture,
                 publication_date_attributes: publication_date_fixture,
                 contact_emails_attributes: contact_emails_fixture,
                 keywords_attributes: keywords_fixture,
                 work_type: work_type_fixture,
                 work_subtypes: work_subtypes_fixture,
                 content_id: 5,
                 access: 'stanford',
                 release_option: 'delay',
                 release_date: release_date_fixture.to_date,
                 custom_rights_statement: custom_rights_statement_fixture,
                 doi_option: 'yes',
                 agree_to_terms: true,
                 create_date_single_attributes: creation_date_single_fixture,
                 create_date_range_from_attributes: creation_date_range_from_fixture,
                 create_date_range_to_attributes: creation_date_range_to_fixture,
                 create_date_type: 'single',
                 whats_changing: whats_changing_fixture,
                 creation_date: creation_date_fixture,
                 deposit_publication_date: deposit_publication_date_fixture,
                 apo: 'druid:hv992ry2431',
                 copyright: copyright_fixture,
                 form_id: form_id_fixture)
  end

  describe '#serialize?' do
    context 'with a Work Form' do
      it 'returns true' do
        expect(described_class.serialize?(WorkForm.new)).to be true
      end
    end

    context 'with something other than a Work Form' do
      it 'returns false' do
        expect(described_class.serialize?(ApplicationForm.new)).to be false
      end
    end
  end

  describe '#serialize' do
    it 'serializes a Work Form' do
      expect(described_class.serialize(work_form)).to eq(serialized_form)
    end
  end

  describe '#deserialize' do
    it 'deserializes a Work Form' do
      expect(described_class.deserialize(serialized_form)).to equal_form(work_form)
    end
  end
end
