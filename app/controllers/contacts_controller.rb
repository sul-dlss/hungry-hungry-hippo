# frozen_string_literal: true

# Controller for the contact form
class ContactsController < ApplicationController
  allow_unauthenticated_access
  skip_verify_authorized

  before_action :set_contact_form_conditions

  def new
    @contact_form = ContactForm.new
    @contact_form.help_how = params[:help_how]

    render :new
  end

  def create # rubocop:disable Metrics/AbcSize
    if (@recaptcha_error = recaptcha_error?)
      flash.delete(:recaptcha_error)
      @contact_form = ContactForm.new(contact_form_params)
      return render :new, status: :unprocessable_content
    end

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
    params.expect(contact: ContactForm.permitted_params)
  end

  def set_contact_form_conditions
    @welcome = params[:welcome] == 'true'
    @modal = params[:modal] == 'true'
  end

  def recaptcha_error?
    Settings.recaptcha.enabled && !verify_recaptcha(action: 'contact', minimum_score: 0.5)
  end
end
