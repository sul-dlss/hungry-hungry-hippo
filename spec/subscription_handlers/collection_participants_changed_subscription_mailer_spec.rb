# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionParticipantsChangedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:current_user) { create(:user) }
  let(:owner) { create(:user) }
  let(:manager) { create(:user) }
  let(:reviewer) { create(:user) }

  context 'when previously deposited collection' do
    let(:collection) do
      create(:collection, user: owner, version: 2, managers: [manager],
                          reviewers: [reviewer], email_when_participants_changed: true)
    end

    it 'sends the collection participants changed email to managers and reviewers' do
      described_class.call(collection:)

      assert_enqueued_email_with CollectionsMailer.with(collection:, user: manager), :participants_changed_email
      assert_enqueued_email_with CollectionsMailer.with(collection:, user: reviewer), :participants_changed_email
    end
  end

  context 'when collection is new' do
    let(:collection) do
      create(:collection,
             title: '20 Minutes into the Future',
             managers: [manager],
             email_when_participants_changed: true,
             version: 1)
    end

    it 'does not render an email' do
      expect do
        described_class.call(collection:)
      end.not_to have_enqueued_mail(CollectionsMailer, :participants_changed_email)
    end
  end

  context 'when collection with email_when_participants_changed false' do
    let(:collection) do
      create(:collection, user: owner, managers: [manager],
                          reviewers: [reviewer], email_when_participants_changed: false)
    end

    it 'sends the collection participants changed email to managers and reviewers' do
      expect do
        described_class.call(collection:)
      end.not_to have_enqueued_mail(CollectionsMailer, :participants_changed_email)
    end
  end

  context 'when a participant is a manager and reviewer' do
    let(:collection) do
      create(:collection, user: owner, version: 2, managers: [manager],
                          reviewers: [manager], email_when_participants_changed: true)
    end

    before do
      allow(CollectionsMailer).to receive(:with).and_call_original
    end

    it 'sends the email to the manager address once' do
      described_class.call(collection:)

      expect(CollectionsMailer).to have_received(:with).with(collection:, user: manager).once
      assert_enqueued_email_with CollectionsMailer.with(collection:, user: manager), :participants_changed_email
    end
  end
end
