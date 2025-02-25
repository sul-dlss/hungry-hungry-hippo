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

    ContactsMailer.with(
      name: contact_form.name,
      affiliation: contact_form.affiliation,
      email_address: contact_form.email_address,
      message: contact_form.message,
      help_how: contact_form.help_how,
      collections: contact_form.selected_collections
    ).jira_email.deliver_later

    @welcome = contact_form.welcome?

    render :success, status: :created
  end

  private

  def contact_form_params
    params.expect(contact: ContactForm.user_editable_attributes)
  end
end
