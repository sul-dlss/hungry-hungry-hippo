# frozen_string_literal: true

# Display the terms of deposit
class TermsController < ApplicationController
  allow_unauthenticated_access
  skip_verify_authorized

  def show
    # Just the default render
  end
end
