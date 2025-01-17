# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCollectionForm::Mapper, type: :mapping do
  subject(:collection_form) { described_class.call(cocina_object: collection_with_metadata_fixture, collection:) }

  let(:collection) do
    create(:collection, druid: collection_druid_fixture, user: manager, managers: [manager], depositors: [depositor])
  end
  let(:manager) { create(:user, email_address: 'stepking@stanford.edu') }
  let(:depositor) { create(:user, email_address: 'joehill@stanford.edu') }

  it 'maps to cocina' do
    expect(collection_form).to equal_form(collection_form_fixture)
  end
end
