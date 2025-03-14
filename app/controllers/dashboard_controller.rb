# frozen_string_literal: true

require 'benchmark'

# Controller for the user dashboard
class DashboardController < ApplicationController
  skip_verify_authorized only: :show

  def show
    return render :welcome_form unless allowed_to?(:show?, :dashboard)

    set_draft_works_and_status_map
    @your_collections = current_user.your_collections.order(:title)
  end

  private

  def druid_to_status_map
    @druid_to_status_map ||= begin
      druids = current_user.your_works.where.not(druid: nil).pluck(:druid)
      statuses = nil
      time = Benchmark.realtime do
        statuses = Sdr::Repository.statuses(druids:)
      end
      Rails.logger.info("FETCHED #{statuses.size} statuses in #{time.round(2)}s")
      statuses
    end
  end

  def set_draft_works_and_status_map
    # This is going to be slow because it is going to block rendering since it is synchronous.
    # Also, it processes all of a user's works, but not all may be rendered on the dashboard.
    @draft_works = []
    @status_map = current_user.your_works.to_h do |work|
      version_status = druid_to_status_map[work.druid] || VersionStatus::NilStatus.new
      @draft_works << work if version_status.draft? && work.user == current_user
      [work.id, version_status]
    end
  end
end
