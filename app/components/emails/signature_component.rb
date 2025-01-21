# frozen_string_literal: true

module Emails
  # Component for rendering an email signature.
  class SignatureComponent < ApplicationComponent
    def call
      tag.p do
        'The Stanford Digital Repository Team'
      end
    end
  end
end
