# frozen_string_literal: true

# Form object for the contact form
class ContactForm < ApplicationForm
  HELP_HOW_CHOICES = [
    'I want to become an SDR depositor',
    'I want to report a problem',
    'I want to ask a question',
    'I want to provide feedback',
    'Request access to another collection'
  ].freeze

  attribute :name, :string
  attribute :email_address, :string
  attribute :affiliation, :string
  attribute :help_how, :string
  attribute :message, :string
  attribute :welcome, :boolean, default: false

  attribute :faculty_student_staff_collection, :boolean, default: false
  attribute :research_data_collection, :boolean, default: false
  attribute :theses_collection, :boolean, default: false
  attribute :library_staff_collection, :boolean, default: false
  attribute :open_access_collection, :boolean, default: false
  attribute :need_marc_record, :boolean, default: false
  attribute :other_collection, :boolean, default: false

  def welcome?
    welcome
  end

  def selected_collections
    %i[faculty_student_staff_collection research_data_collection theses_collection library_staff_collection
       open_access_collection need_marc_record other_collection].filter do |collection|
      public_send(collection)
    end
  end
end
