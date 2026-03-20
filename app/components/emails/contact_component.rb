# frozen_string_literal: true

module Emails
  # Component for providing contact info.
  class ContactComponent < ApplicationComponent
    def call
      tag.p(link_to('Contact us with questions.', new_contacts_url))
    end
  end
end
