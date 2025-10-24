# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositWorkJob do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:content) { create(:content) }
  let(:collection) { create(:collection, druid: collection_druid_fixture) }
  let(:user) { create(:user) }
  let(:work) { create(:work, :registering_or_updating, collection:, user:) }
  let(:work_form) do
    new_work_form_fixture.tap do |form|
      form.content_id = content.id
      form.collection_druid = collection.druid
    end
  end

  before do
    allow(WorkDepositor).to receive(:call)
  end

  it 'passes its args to the work depositor service to do the heavy lifting' do
    described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user: user)
    expect(WorkDepositor).to have_received(:call).with(work_form:, work:, deposit: true, request_review: false, current_user: user)
  end
end
