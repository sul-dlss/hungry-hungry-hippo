# frozen_string_literal: true

# Controller for the user dashboard
class DashboardController < ApplicationController
  skip_verify_authorized only: :show

  def show
    # This is going to be slow because it makes a call to DSA for each work.
    # It is also going to block rendering since it is synchronous.
    # Also, it processes all of a user's works, but not all may be rendered on the dashboard.
    @draft_works = []
    @status_map = current_user.works.to_h do |work|
      status = work.druid ? Sdr::Repository.status(druid: work.druid) : nil
      @draft_works << work if status&.open?
      [work.id, StatusPresenter.new(status: status)]
    end
  end
end
