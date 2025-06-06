# frozen_string_literal: true

module Admin
  # Controller for displaying recent activity for works and collections.
  class RecentActivityController < Admin::ApplicationController
    def index
      authorize!

      @type = type
      @label = label
      @recent_activity_form = Admin::RecentActivityForm.new(**recent_activity_params)
      @items = klass.where('updated_at > ?', days_limit.days.ago).order('updated_at DESC')
    end

    private

    # Gets the class based on the type parameter to be queried.
    def klass
      type.classify.constantize
    end

    def label
      type == 'works' ? 'Items' : 'Collections'
    end

    def type
      params.fetch(:admin_recent_activity, {}).fetch(:type)
    end

    def days_limit
      params.fetch(:admin_recent_activity, {}).fetch(:days_limit, 7).to_i
    end

    def recent_activity_params
      params.expect(admin_recent_activity: %i[type days_limit])
    end
  end
end
