# frozen_string_literal: true

module Admin
  # Controller for searching for collections
  class CollectionSearchController < Admin::ApplicationController
    def new
      authorize!
    end

    def search
      authorize!

      @collections = Collection.where('title ILIKE ?', "%#{params[:q]}%").where.not(druid: nil).order(:title).limit(20)
      render layout: false
    end
  end
end
