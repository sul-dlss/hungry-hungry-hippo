# frozen_string_literal: true

module Admin
  # Controller for changing ownership of resources
  class ChangeOwnerController < Admin::ApplicationController
    def new
      authorize!

      @change_owner_form = Admin::ChangeOwnerForm.new(content_id: params[:content_id])
      render :form
    end

    def create
      authorize!

      @change_owner_form = Admin::ChangeOwnerForm.new(work_form:, **change_owner_params)
      work_form.content_id = @change_owner_form.content_id

      Admin::ChangeOwner.call(work_form:, work:, user:, admin_user: current_user, ahoy_visit:)

      render_change_owner_success
    end

    private

    def change_owner_params
      params.expect(admin_change_owner: %i[content_id sunetid name])
    end

    def work
      return @work if defined?(@work)

      @work = Work.find_by(druid: params[:work_druid])
    end

    def account
      return AccountService.call(sunetid: @change_owner_form.sunetid) unless Rails.env.development?

      AccountService::Account.new(name: @change_owner_form.sunetid,
                                  sunetid: @change_owner_form.sunetid,
                                  description: 'Digital Library Systems and Services')
    end

    def user
      @user ||= User.find_or_create_by!(email_address:) do |user|
        user.name = account.name
      end
    end

    def email_address
      @email_address ||= "#{@change_owner_form.sunetid}#{::User::EMAIL_SUFFIX}"
    end

    def cocina_object
      @cocina_object ||= Sdr::Repository.find(druid: params[:work_druid])
    end

    def work_form
      @work_form ||= Form::WorkMapper.call(cocina_object:,
                                           doi_assigned: DoiAssignedService.call(cocina_object:, work:),
                                           agree_to_terms: current_user.agree_to_terms?,
                                           version_description: 'Changing ownership',
                                           collection: work.collection)
    end

    def render_change_owner_success
      flash[:success] = I18n.t('messages.work_ownership_changed', new_owner: user.name)
      # This breaks out of the turbo frame.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(:full_page_redirect, wait_works_path(work.id))
        end
      end
    end

    def ahoy_visit
      @ahoy_visit ||= ahoy.visit
    end
  end
end
