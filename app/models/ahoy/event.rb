# frozen_string_literal: true

module Ahoy
  # Event model for Ahoy tracking
  class Event < ApplicationRecord
    include Ahoy::QueryMethods

    # Event names
    TOOLTIP_CLICKED = 'tooltip clicked'
    WORK_FORM_STARTED = 'work form started' # User is presented with a work form
    WORK_FORM_COMPLETED = 'work form completed' # User has submitted a valid work form
    FORM_CHANGED = 'form changed' # User has changed a form
    FILES_UPLOADED = 'files uploaded' # User has uploaded files
    WORK_CREATED = 'work created'
    WORK_UPDATED = 'work updated'
    UNCHANGED_WORK_SUBMITTED = 'unchanged work submitted'
    INVALID_WORK_SUBMITTED = 'invalid work submitted'

    self.table_name = 'ahoy_events'

    belongs_to :visit
    belongs_to :user, optional: true
  end
end
