# frozen_string_literal: true

module Admin
  # Controller for deleting a Collection as an administrator
  class DeleteCollectionController < Admin::ApplicationController
    before_action :set_collection

    def new
      authorize!

      render :form
    end

    def destroy
      authorize!

      collection.destroy!
      render_delete_success
    end

    attr_reader :collection_form, :collection

    private

    def druid
      params[:collection_druid]
    end

    def set_collection
      @collection = Collection.find_by(druid:)
    end

    def render_delete_success
      flash[:success] = I18n.t('messages.collection_deleted')
      # This breaks out of the turbo frame.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(:full_page_redirect, dashboard_path)
        end
      end
    end
  end
end
