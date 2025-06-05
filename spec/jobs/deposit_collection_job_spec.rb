# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCollectionJob do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:cocina_object) { collection_with_metadata_fixture }
  let(:current_user) { create(:user) }

  before do
    allow(Cocina::CollectionMapper).to receive(:call).and_call_original
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Event).to receive(:create)
  end

  context 'when a new collection' do
    let(:collection_form) { CollectionForm.new(title: collection.title, managers_attributes:, depositors_attributes:) }
    let(:collection) { create(:collection, :registering_or_updating) }
    let(:managers_attributes) { [{ sunetid: manager.sunetid }, { sunetid: 'stepking', name: 'Stephen King' }] }
    let(:depositors_attributes) { [{ sunetid: 'joehill', name: 'Joe Hill' }] }
    let(:manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new collection' do
      described_class.perform_now(collection_form:, collection:, current_user:)
      new_manager = User.find_by(email_address: 'stepking@stanford.edu')
      new_depositor = User.find_by(email_address: 'joehill@stanford.edu')
      expect(Cocina::CollectionMapper).to have_received(:call).with(collection_form:,
                                                                    source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestCollection), user_name: current_user.sunetid)
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(collection.reload.accessioning?).to be true

      # These expectations verify that the new manager and depositor were created and associated with the collection.
      # As well as verifying that an existing managers name is not overwritten.
      expect(collection.managers).to include(manager, new_manager)
      expect(collection.depositors).to include(new_depositor)
      expect(manager.manages).to contain_exactly(collection)
      expect(new_manager.manages).to contain_exactly(collection)
      expect(new_depositor.depositor_for).to contain_exactly(collection)
      expect(new_manager.name).to eq('Stephen King')
      expect(new_depositor.name).to eq('Joe Hill')
      expect(manager.name).not_to eq(manager.sunetid)
      expect(collection.email_when_participants_changed).to be true
      expect(collection.email_depositors_status_changed).to be true

      expect(collection.custom_rights_statement_option).to eq('no') # default

      # Verifying that Current.user is being set for notifications
      expect(Current.user).to eq current_user

      expect(Sdr::Event).not_to have_received(:create)
    end

    context 'when a custom rights statement is provided' do
      let(:collection_form) do
        CollectionForm.new(title: collection.title,
                           managers_attributes: [],
                           depositors_attributes: [],
                           custom_rights_statement_option: 'provided',
                           provided_custom_rights_statement: 'This is a custom rights statement')
      end

      it 'registers a new collection with a custom rights statement' do
        described_class.perform_now(collection_form:, collection:, current_user:)
        expect(collection.reload.custom_rights_statement_option).to eq('provided')
        expect(collection.provided_custom_rights_statement).to eq('This is a custom rights statement')

        expect(Sdr::Event).not_to have_received(:create)
      end
    end

    context 'when the depositor can enter the custom rights statement' do
      let(:collection_form) do
        CollectionForm.new(title: collection.title,
                           managers_attributes: [],
                           depositors_attributes: [],
                           custom_rights_statement_option: 'depositor_selects',
                           custom_rights_statement_instructions: 'Please enter a custom rights statement')
      end

      it 'registers a new collection with instructions for entering the rights statement' do
        described_class.perform_now(collection_form:, collection:, current_user:)
        expect(collection.reload.custom_rights_statement_option).to eq('depositor_selects')
        expect(collection.reload.custom_rights_statement_instructions).to eq('Please enter a custom rights statement')

        expect(Sdr::Event).not_to have_received(:create)
      end
    end
  end

  context 'when an existing collection with changed cocina object' do
    let(:collection_form) { collection_form_fixture }
    let(:collection) do
      create(:collection, :registering_or_updating, druid:, access: 'stanford', doi_option: 'no',
                                                    release_duration: '2 years', license_option: 'depositor_selects',
                                                    review_enabled: true,
                                                    provided_custom_rights_statement: 'My original rights statement',
                                                    depositors: [depositor])
    end
    let(:depositor) { create(:user, name: 'A. Depositor') }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
      allow(Notifier).to receive(:publish)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form:, collection:, current_user:)
      expect(Cocina::CollectionMapper).to have_received(:call).with(collection_form:,
                                                                    source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::CollectionWithMetadata), user_name: current_user.sunetid)
      expect(Sdr::Repository).to have_received(:update).with(cocina_object:, user_name: current_user.sunetid)
      expect(Sdr::Repository).to have_received(:accession)
      expect(RoundtripSupport).to have_received(:changed?)
      expect(Notifier).not_to have_received(:publish).with(Notifier::DEPOSIT_PERSIST_COMPLETE)

      expect(collection.reload.title).to eq(collection_title_fixture)
      expect(collection.version).to eq(2)
      expect(collection.access).to eq('depositor_selects')
      expect(collection.release_option).to eq('depositor_selects')
      expect(collection.release_duration).to eq('one_year')
      expect(collection.license_option).to eq('required')
      expect(collection.license).to eq(collection_license_fixture)
      expect(collection.custom_rights_statement_option).to eq('provided')
      expect(collection.provided_custom_rights_statement).to eq('My custom rights statement')
      expect(collection.custom_rights_statement_instructions).to eq('My custom rights statement instructions')
      expect(collection.doi_option).to eq('yes')
      expect(collection.review_enabled).to be false
      expect(collection.work_type).to eq(work_type_fixture)
      expect(collection.work_subtypes).to eq(work_subtypes_fixture)
      expect(collection.works_contact_email).to eq(works_contact_email_fixture)
      expect(collection.deposit_not_in_progress?).to be false

      expect(Sdr::Event).to have_received(:create)
        .with(druid: collection.druid,
              type: 'h3_collection_settings_updated',
              data: {
                changes: 'Release settings modified, Access setting modified, DOI setting modified, ' \
                         'License setting modified, Notification settings modified, ' \
                         'Review workflow settings modified, Custom terms of use modified, ' \
                         'Added depositors: Joseph Hill, Removed depositors: A. Depositor',
                who: current_user.sunetid
              })
    end
  end

  context 'when an existing collection with unchanged cocina object' do
    let(:collection_form) { CollectionForm.new(title: collection_title_fixture, druid:, lock: 'abc123') }
    let(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form:, collection:, current_user:)
      expect(Cocina::CollectionMapper).to have_received(:call).with(collection_form:,
                                                                    source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).not_to have_received(:open_if_needed)
      expect(Sdr::Repository).not_to have_received(:update)
      expect(Sdr::Repository).not_to have_received(:accession)
      expect(RoundtripSupport).to have_received(:changed?)

      expect(collection.deposit_not_in_progress?).to be true
    end
  end

  context 'when adding participants to an existing collection with an unchanged cocina object' do
    let(:collection_form) do
      CollectionForm.new(title: collection_title_fixture,
                         druid:,
                         lock: 'abc123',
                         managers_attributes:)
    end
    let(:collection) { create(:collection, :registering_or_updating, druid:) }
    let(:managers_attributes) { [{ sunetid: manager.sunetid }] }
    let(:manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Notifier).to receive(:publish)
    end

    it 'publishes a MANGER_ADDED notification' do
      described_class.perform_now(collection_form:, collection:, current_user:)
      expect(collection.managers).to include(manager)
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:, user: manager)
    end
  end

  context 'when removing participants to an existing collection with an unchanged cocina object' do
    let(:collection_form) do
      CollectionForm.new(title: collection_title_fixture,
                         druid:,
                         lock: 'abc123',
                         managers_attributes:)
    end
    let(:collection) do
      create(:collection, :registering_or_updating, druid:, managers: [first_manager, second_manager])
    end
    let(:managers_attributes) { [{ sunetid: first_manager.sunetid }] }
    let(:first_manager) { create(:user) }
    let(:second_manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Notifier).to receive(:publish)
    end

    it 'only publishes a MANGER_REMOVED notification' do
      described_class.perform_now(collection_form:, collection:, current_user:)
      expect(collection.managers).to include(first_manager)
      expect(collection.managers).not_to include(second_manager)
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_REMOVED, collection:, user: second_manager)
      expect(Notifier).not_to have_received(:publish).with(Notifier::MANAGER_ADDED)
    end
  end

  context 'when adding contributors to an existing collection with an unchanged cocina object' do
    let(:collection_form) do
      CollectionForm.new(title: collection_title_fixture,
                         druid:,
                         lock: 'abc123',
                         contributors_attributes:)
    end
    let(:collection) { create(:collection, :registering_or_updating, druid:, contributors: [existing_contributor]) }
    let(:contributors_attributes) do
      [
        {
          'first_name' => 'Jonathan',
          'last_name' => 'Levin',
          'person_role' => 'researcher',
          'role_type' => 'person',
          'with_orcid' => true,
          'orcid' => '0000-0000-0000-0000',
          'cited' => true
        },
        {
          'organization_name' => 'Stanford University',
          'role_type' => 'organization',
          'organization_role' => 'degree_granting_institution',
          'stanford_degree_granting_institution' => true,
          'suborganization_name' => 'Graduate School of Business',
          'cited' => true
        },
        {
          'organization_name' => 'Massachusetts Institute of Technology',
          'role_type' => 'organization',
          'organization_role' => 'research_group',
          'stanford_degree_granting_institution' => false,
          'cited' => false
        }
      ]
    end

    let(:existing_contributor) { create(:person_contributor) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Notifier).to receive(:publish)
    end

    it 'removes existing contributors and adds new contributors' do
      described_class.perform_now(collection_form:, collection:, current_user:)

      expect(Contributor.exists?(existing_contributor.id)).to be false

      expect(collection.reload.contributors.count).to eq(3)

      person_contributor = collection.contributors[0]
      expect(person_contributor.first_name).to eq('Jonathan')
      expect(person_contributor.last_name).to eq('Levin')
      expect(person_contributor.role).to eq('researcher')
      expect(person_contributor.role_type).to eq('person')
      expect(person_contributor.orcid).to eq('0000-0000-0000-0000')
      expect(person_contributor.cited).to be true

      stanford_contributor = collection.contributors[1]
      expect(stanford_contributor.organization_name).to eq('Stanford University')
      expect(stanford_contributor.role_type).to eq('organization')
      expect(stanford_contributor.role).to eq('degree_granting_institution')
      expect(stanford_contributor.suborganization_name).to eq('Graduate School of Business')
      expect(stanford_contributor.cited).to be true

      organization_contributor = collection.contributors[2]
      expect(organization_contributor.organization_name).to eq('Massachusetts Institute of Technology')
      expect(organization_contributor.role_type).to eq('organization')
      expect(organization_contributor.role).to eq('research_group')
      expect(organization_contributor.cited).to be false
    end
  end

  context 'when an existing collection with no setting changes' do
    let(:collection_form) do
      CollectionForm.new(collection.attributes
      .except('id', 'user_id', 'created_at', 'updated_at', 'object_updated_at', 'deposit_state')
                    .merge(lock: 'abc123'))
    end
    let(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
      allow(Notifier).to receive(:publish)
    end

    it 'does not submit an SDR event' do
      described_class.perform_now(collection_form:, collection:, current_user:)

      expect(Sdr::Event).not_to have_received(:create)
    end
  end
end
