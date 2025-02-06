# frozen_string_literal: true

module Structure
  # Component for rendering the contact form response
  class ContactFormSuccessComponent < ApplicationComponent
    def initialize(bounce_location: nil)
      @bounce_location = bounce_location
      super()
    end

    private

    def bounce_location?
      @bounce_location.present?
    end

    def close_button_params
      return { link: @bounce_location, label: 'Close', variant: :link } if bounce_location?

      { data: { bs_dismiss: 'modal' }, link: '#', label: 'Close', variant: :link }
    end

    def containing_tag_name
      return :div if bounce_location?

      :turbo_frame
    end

    def containing_tag_args
      return {} if bounce_location?

      { id: 'contact-form' }
    end
  end
end
