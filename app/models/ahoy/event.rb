# frozen_string_literal: true

module Ahoy
  # Event model for Ahoy tracking
  class Event < ApplicationRecord
    include Ahoy::QueryMethods

    # Event names
    TOOLTIP_CLICKED = 'tooltip clicked'
    WORK_FORM_STARTED = 'work form started' # User is presented with a work form
    WORK_FORM_COMPLETED = 'work form completed' # User has submitted a valid work form
    ARTICLE_FORM_STARTED = 'article form started' # User is presented with an article form
    ARTICLE_FORM_COMPLETED = 'article form completed' # User has submitted a valid article form
    FORM_CHANGED = 'form changed' # User has changed a form
    FILES_UPLOADED = 'files uploaded' # User has uploaded files
    WORK_CREATED = 'work created'
    ARTICLE_CREATED = 'article created'
    WORK_UPDATED = 'work updated'
    UNCHANGED_WORK_SUBMITTED = 'unchanged work submitted'
    INVALID_WORK_SUBMITTED = 'invalid work submitted'
    GLOBUS_CREATED = 'globus created' # User has initiated Globus upload
    GLOBUS_STAGED = 'globus staged' # User has confirmed Globus upload is complete

    self.table_name = 'ahoy_events'

    belongs_to :visit
    belongs_to :user, optional: true
  end
end
