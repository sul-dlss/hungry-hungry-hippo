# frozen_string_literal: true

module Admin
  # Controller for displaying recent activity for collections
  class RecentActivityCollectionsController < Admin::ApplicationController
    def index
      authorize!

      @form = Admin::RecentActivityForm.new(**recent_activity_params)
      @rows = rows
    end

    private

    def days_limit
      recent_activity_params.fetch(:days_limit, Admin::RecentActivityForm::DEFAULT_DAYS_LIMIT).to_i
    end

    def recent_activity_params
      params.fetch(:admin_recent_activity, {}).permit(:days_limit)
    end

    def rows
      Collection.where('updated_at > ?', days_limit.days.ago).order('updated_at DESC').map do |collection|
        Admin::RecentActivityCollectionPresenter.values_for(collection:)
      end
    end
  end
end
