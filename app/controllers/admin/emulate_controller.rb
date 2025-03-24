# frozen_string_literal: true

module Admin
  # Allows an admin to emulate not being an admin.
  class EmulateController < Admin::ApplicationController
    def new
      authorize!
    end

    def create
      authorize!

      # This cookie will be used by authentication to override the groups provided by apache.
      cookies[:emulate_not_admin] = true
      redirect_to dashboard_path
    end
  end
end
