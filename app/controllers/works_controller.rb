# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  def show
    # Stubbing this out temporarily until we have retrieving from the repository.
    @work_form = WorkForm.new(title: "My Title for #{params[:druid]}")
  end

  def new
    @work_form = WorkForm.new
  end

  def create
    @work_form = WorkForm.new(work_params)
  end
end
