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
      'authors_attributes' => authors_fixture,
      'citation' => citation_fixture,
      'auto_generate_citation' => false,
      'related_links_attributes' => related_links_fixture,
      'related_works_attributes' => related_works_fixture,
      'license' => license_fixture,
      'publication_date_attributes' => publication_date_fixture,
      'contact_emails_attributes' => contact_emails_fixture,
      'keywords_attributes' => keywords_fixture,
      'work_type' => work_type_fixture,
      'work_subtypes' => work_subtypes_fixture,
      'other_work_subtype' => nil,
      'content_id' => 5
    }
  end
  let(:work_form) do
    WorkForm.new(title: title_fixture,
                 druid:,
                 collection_druid: collection_druid_fixture,
                 abstract: abstract_fixture,
                 authors_attributes: authors_fixture,
                 citation: citation_fixture,
                 auto_generate_citation: false,
                 related_links_attributes: related_links_fixture,
                 related_works_attributes: related_works_fixture,
                 license: license_fixture,
                 publication_date_attributes: publication_date_fixture,
                 contact_emails_attributes: contact_emails_fixture,
                 keywords_attributes: keywords_fixture,
                 work_type: work_type_fixture,
                 work_subtypes: work_subtypes_fixture,
                 content_id: 5)
  end

  describe '.serialize?' do
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

  describe '.serialize' do
    it 'serializes a Work Form' do
      expect(described_class.serialize(work_form)).to eq(serialized_form)
    end
  end

  describe '.deserialize' do
    it 'deserializes a Work Form' do
      expect(described_class.deserialize(serialized_form)).to equal_form(work_form)
    end
  end
end
