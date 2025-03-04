# frozen_string_literal: true

FactoryBot.define do
  factory :version_status do
    version { 2 }
    open { false }
    openable { false }
    # assembling { false }
    accessioning { false }
    # closeable { false }
    discardable { false }
    version_description { whats_changing_fixture }

    initialize_with do
      new(status: Dor::Services::Client::ObjectVersion::VersionStatus.new(open:, versionId: version, openable:,
                                                                          accessioning:, discardable:,
                                                                          versionDescription: version_description))
    end

    factory :openable_version_status do
      openable { true }
    end

    factory :accessioning_version_status do
      accessioning { true }
      # Also not open or openable
    end

    factory :draft_version_status do
      open { true }
      discardable { true }
    end

    factory :first_draft_version_status do
      open { true }
      version { 1 }
      discardable { true }
      version_description { 'Initial version' }
    end

    factory :first_accessioning_version_status do
      accessioning { true }
      version { 1 }
      version_description { 'Initial version' }
      # Also not open or openable
    end

    factory :first_version_status do
      version { 1 }
      version_description { 'Initial version' }
    end
  end
end
