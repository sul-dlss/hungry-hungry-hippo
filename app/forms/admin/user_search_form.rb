# frozen_string_literal: true

module Admin
  # Admin form object for searching for a user by SUNet ID.
  class UserSearchForm < ApplicationForm
    attribute :sunetid, :string
    validate :user_exists

    def user
      @user ||= User.find_by_sunetid(sunetid:)
    end

    def user_exists
      return if user.present?

      errors.add(:sunetid, I18n.t('admin_user_search_form.fields.sunetid.validations.not_found'))
    end
  end
end
