# frozen_string_literal: true

module Admin
  # Controller for searching for work or collection by druid
  class DruidSearchController < Admin::ApplicationController
    def new
      authorize!

      @druid_search_form = DruidSearchForm.new
    end

    def search
      authorize!

      @druid_search_form = DruidSearchForm.new(druid_search_form_params)
      if @druid_search_form.valid?
        redirect_to_work_or_collection
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def redirect_to_work_or_collection
      path = if @druid_search_form.collection.present?
               collection_path(@druid_search_form.druid)
             else
               work_path(@druid_search_form.druid)
             end
      render turbo_stream: turbo_stream.action(:full_page_redirect, path)
    end

    def druid_search_form_params
      params.expect(admin_druid_search: DruidSearchForm.permitted_params)
    end
  end
end
