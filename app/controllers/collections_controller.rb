# frozen_string_literal: true

# Controller for a Collection
class CollectionsController < ApplicationController
  def show
    @collection = Collection.find_by!(druid: params[:druid])
  end
end
