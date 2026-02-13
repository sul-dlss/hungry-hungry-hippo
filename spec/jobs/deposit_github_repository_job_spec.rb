# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositGithubRepositoryJob do
  include WorkMappingFixtures

  let(:work) { create(:github_repository, github_deposit_enabled: false) }
  let(:work_form) { instance_double(GithubRepositoryForm) }
  let(:current_user) { create(:user) }

  before do
    allow(DepositWorkJob).to receive(:perform_now)
  end

  context 'when depositing' do
    it 'performs the job and updates the github_deposit_enabled flag' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)
      end.to change(work.reload, :github_deposit_enabled).from(false).to(true)
      expect(DepositWorkJob).to have_received(:perform_now).with(work:, work_form:, deposit: false,
                                                                 request_review: false, current_user:)
    end
  end

  context 'when not depositing' do
    it 'performs the job without updating the github_deposit_enabled flag' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: false, request_review: false, current_user:)
      end.not_to change(work.reload, :github_deposit_enabled)
      expect(DepositWorkJob).to have_received(:perform_now).with(work:, work_form:, deposit: false,
                                                                 request_review: false, current_user:)
    end
  end
end
