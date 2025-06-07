# frozen_string_literal: true

module Admin
  # Controller for displaying recent activity for works and collections.
  class RecentActivityController < Admin::ApplicationController
    TABLE_HEADERS = {
      'works' => [{ label: 'Item title' }, { label: 'Collection' }],
      'collections' => [{ label: 'Collections' }]
    }.freeze

    def index
      authorize!

      @type = type
      @label = label
      @presenter = presenter_for_type
      @headers = TABLE_HEADERS[type]
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

    def presenter_for_type
      "Admin::RecentActivity#{type.classify}Presenter".constantize
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
