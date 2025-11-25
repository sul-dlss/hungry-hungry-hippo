# frozen_string_literal: true

module Admin
  # Controller for searching for and showing information about a user
  class UsersSearchController < Admin::ApplicationController
    def new
      authorize!

      @user_search_form = UserSearchForm.new
    end

    def search
      authorize!
      @user_search_form = UserSearchForm.new(user_search_form_params)

      if @user_search_form.valid?
        @user = @user_search_form.user
        @status_map = get_status_map(@user)
        render :new
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def get_status_map(user)
      druid_to_status_map = Sdr::Repository.statuses(druids: user.works.where.not(druid: nil).pluck(:druid))
      user.works.to_h do |work|
        version_status = druid_to_status_map[work.druid] || VersionStatus::NilStatus.new
        [work.id, version_status]
      end
    end

    def user_search_form_params
      params.expect(admin_user_search: UserSearchForm.permitted_params)
    end
  end
end
