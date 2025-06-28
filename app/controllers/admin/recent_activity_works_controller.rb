# frozen_string_literal: true

module Admin
  # Controller for displaying recent activity for works
  class RecentActivityWorksController < Admin::ApplicationController
    def index
      authorize!

      @form = Admin::RecentActivityForm.new(**recent_activity_params)
      @rows = rows
      @sort_by = sort_by
      @days_limit = days_limit
    end

    private

    def days_limit
      recent_activity_params.fetch(:days_limit, Admin::RecentActivityForm::DEFAULT_DAYS_LIMIT).to_i
    end

    def recent_activity_params
      params.fetch(:admin_recent_activity, {}).permit(:days_limit)
    end

    def sort_by
      params[:sort_by] || 'updated_at DESC'
    end

    def rows
      Work.where('updated_at > ?', days_limit.days.ago).order(sort_by).map do |work|
        Admin::RecentActivityWorkPresenter.values_for(work:)
      end
    end
  end
end
