# frozen_string_literal: true

module Structure
  # Component for rendering the terms of deposit modal
  class TermsOfDepositModalComponent < ApplicationComponent
    def loading
      # Lazy loading is problematic in tests, so we disable it there.
      Rails.env.test? ? nil : 'lazy'
    end
  end
end
