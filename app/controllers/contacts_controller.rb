# frozen_string_literal: true

# Controller for the contact form
class ContactsController < ApplicationController
  skip_verify_authorized

  before_action :set_contact_form_conditions

  def new
    @contact_form = ContactForm.new
    @contact_form.help_how = 'Request access to another collection' if params[:show_collections] == 'true'

    render :new
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

    render :success, status: :created
  end

  private

  def contact_form_params
    params.expect(contact: ContactForm.user_editable_attributes)
  end

  def set_contact_form_conditions
    @welcome = params[:welcome] == 'true'
    @modal = params[:modal] == 'true'
  end
end
