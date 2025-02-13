# frozen_string_literal: true

module Structure
  # Component for rendering a contact form modal.
  class ContactFormModalComponent < ApplicationComponent
    def contact_sdr
      I18n.t('contact_sdr')
    end

    def loading
      # Lazy loading is problematic in tests, so we disable it there.
      Rails.env.test? ? nil : 'lazy'
    end
  end
end
