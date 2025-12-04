# frozen_string_literal: true

# Controller for Shares
class SharesController < ApplicationController
  before_action :set_work

  def new
    authorize! @work, with: SharePolicy

    @form = WorkShareForm.new(
      shares_attributes: @work.shares.map do |share|
        {
          sunetid: share.user.sunetid,
          name: share.user.name,
          permission: share.permission
        }
      end
    )
  end

  def create
    authorize! @work, with: SharePolicy

    form = WorkShareForm.new(**share_params)
    ShareUpdater.call(work: @work, form:) # ShareUpdater is defined inline below.

    redirect_to work_path(@work)
  end

  private

  def set_work
    @work = Work.find_by!(druid: params[:work_druid])
  end

  def share_params
    if params.include?(:work_share)
      params.expect(work_share: WorkShareForm.permitted_params)
    else
      { shares_attributes: [] }
    end
  end

  # Updates the shares of a work based on the provided form.
  class ShareUpdater
    def self.call(...)
      new(...).call
    end

    def initialize(work:, form:)
      @work = work
      @form = form
    end

    def call
      add_shares
      update_shares
      remove_shares
    end

    private

    attr_reader :work, :form

    def new_shares_map
      @new_shares_map ||= form.shares.index_by(&:sunetid)
    end

    def existing_shares_map
      @existing_shares_map ||= work.shares.index_by { |share| share.user.sunetid }
    end

    def add_shares
      (new_shares_map.keys - existing_shares_map.keys).each do |sunetid|
        share_form = new_shares_map[sunetid]
        user = user_for(share_form)

        work.shares.create!(user:, permission: share_form.permission) if user != work.user
      end
    end

    def update_shares
      (new_shares_map.keys & existing_shares_map.keys).each do |sunetid|
        existing_share = existing_shares_map[sunetid]
        new_share = new_shares_map[sunetid]
        existing_share.update!(permission: new_share.permission) if existing_share.permission != new_share.permission
      end
    end

    def remove_shares
      (existing_shares_map.keys - new_shares_map.keys).each do |sunetid|
        existing_shares_map[sunetid].destroy!
      end
    end

    def user_for(share_form)
      User.create_with(name: share_form.name)
          .find_or_create_by!(email_address: "#{share_form.sunetid}#{User::EMAIL_SUFFIX}")
    end
  end
end
