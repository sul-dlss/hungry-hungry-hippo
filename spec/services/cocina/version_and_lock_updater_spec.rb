# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::VersionAndLockUpdater do
  include WorkMappingFixtures

  subject(:updated_cocina_object) do
    described_class.call(cocina_object:, version:, lock:)
  end

  let(:cocina_object) do
    dro_with_structural_and_metadata_fixture
  end

  let(:version) { 3 }
  let(:lock) { 'bcd234' }

  it 'updates the version and lock' do
    expect(updated_cocina_object.lock).to eq lock
    expect(updated_cocina_object.version).to eq version
    expect(updated_cocina_object.structural.contains.first.version).to eq version
    expect(updated_cocina_object.structural.contains.first.structural.contains.first.version).to eq version
  end
end
