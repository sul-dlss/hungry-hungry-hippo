# frozen_string_literal: true

module Emails
  # Component for rendering an email salutation.
  class SalutationComponent < ApplicationComponent
    def initialize(user:)
      @user = user
      super()
    end

    def call
      tag.p do
        "Dear #{first_name},"
      end
    end

    delegate :first_name, to: :@user
  end
end
