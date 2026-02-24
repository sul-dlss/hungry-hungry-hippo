# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubRepository do
  describe '#update_settings_from_form' do
    # self.github_deposit_enabled = github_deposit_enabled.nil? || work_form.github_deposit_enabled
    context 'when github_deposit_enabled is nil' do
      let(:work) { create(:github_repository, github_deposit_enabled: nil) }
      let(:work_form) { instance_double(WorkForm) }

      it 'change settings' do
        # A Work does not have any settings, so this should not change anything.
        expect { work.update_settings_from_form(work_form:) }.to change(work, :github_deposit_enabled).to(true)
      end
    end

    context 'when github_deposit_enabled is changed by form' do
      let(:work) { create(:github_repository, github_deposit_enabled: true) }
      let(:work_form) { instance_double(WorkForm, github_deposit_enabled: false) }

      it 'change settings' do
        expect { work.update_settings_from_form(work_form:) }.to change(work, :github_deposit_enabled).to(false)
      end
    end
  end
end
