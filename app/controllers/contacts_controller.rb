# frozen_string_literal: true

# Controller for the contact form
class ContactsController < ApplicationController
  skip_verify_authorized

  def new
    @contact_form = ContactForm.new(welcome: params[:welcome])

    render :new, layout: false
  end

  def create
    contact_form = ContactForm.new(contact_form_params)

    ContactsMailer.with(contact_form.attributes.symbolize_keys).jira_email.deliver_later

    redirect_to success_contacts_path(welcome: contact_form.welcome?)
  end

  private

  def contact_form_params
    params.expect(contact: %i[name email_address affiliation help_how message welcome])
  end
end
