# frozen_string_literal: true

module Admin
  # Controller for searching for and showing information about a user
  class UsersController < Admin::ApplicationController
    def index
      authorize!

      if params[:commit]
        @user_form = Admin::UserForm.new(**user_params)
        @user = User.find_by_sunetid(sunetid: @user_form.sunetid)
        @user_form.errors.add(:sunetid, 'user not found') unless @user
      else
        @user_form = Admin::UserForm.new
      end
    end

    def show
      authorize!

      @user = User.find_by_sunetid(sunetid: params[:sunetid])

      druid_to_status_map = Sdr::Repository.statuses(druids: @user.works.where.not(druid: nil).pluck(:druid))
      @status_map = @user.works.to_h do |work|
        version_status = druid_to_status_map[work.druid] || VersionStatus::NilStatus.new
        [work.id, version_status]
      end
    end

    private

    def user_params
      params.expect(admin_user: [:sunetid])
    end
  end
end
