# frozen_string_literal: true

# Controller for the user dashboard
class DashboardController < ApplicationController
  skip_verify_authorized only: :show

  def show
    # This is going to be slow because it is going to block rendering since it is synchronous.
    # Also, it processes all of a user's works, but not all may be rendered on the dashboard.
    druid_to_status_map = Sdr::Repository.statuses(druids: druids_for_works_for_current_user)
    @draft_works = []
    @status_map = current_user.works.to_h do |work|
      version_status = druid_to_status_map[work.druid] || VersionStatus::NilStatus.new
      @draft_works << work if version_status.draft?
      [work.id, version_status]
    end
  end

  private

  def druids_for_works_for_current_user
    current_user.works.where.not(druid: nil).pluck(:druid)
  end
end
