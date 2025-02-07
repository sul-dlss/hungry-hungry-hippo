# frozen_string_literal: true

# Controller for the contact form
class ContactsController < ApplicationController
  skip_verify_authorized

  def new; end

  def create
    contact_form = ContactForm.new(contact_form_params)

    ContactsMailer.with(contact_form.attributes.symbolize_keys).jira_email.deliver_later

    @bounce_location = params.dig(:contact, :bounce_location)

    render :success, status: :created
  end

  private

  def contact_form_params
    params.expect(contact: %i[name email_address affiliation help_how message])
  end
end
