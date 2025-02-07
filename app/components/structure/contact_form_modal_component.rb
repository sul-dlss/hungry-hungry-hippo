# frozen_string_literal: true

module Structure
  # Component for rendering a contact form modal.
  class ContactFormModalComponent < ApplicationComponent
    def contact_sdr
      I18n.t('contact_sdr')
    end
  end
end
