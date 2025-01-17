# frozen_string_literal: true

# Model for a collection.
# Note that this model does not contain any cocina data.
class Collection < ApplicationRecord
  belongs_to :user
  has_many :works, dependent: :destroy

  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :managers, class_name: 'User', join_table: 'managers'
  has_and_belongs_to_many :reviewers, class_name: 'User', join_table: 'reviewers'

  before_create :add_user_as_manager

  enum :release_option, { immediate: 'immediate', depositor_selects: 'depositor_selects' }, suffix: true
  enum :release_duration, { six_months: '6 months', one_year: '1 year', two_years: '2 years', three_years: '3 years' },
       suffix: true

  RELEASE_DURATION_OPTIONS = { '6 months in the future': 'six_months',
                               '1 year in the future': 'one_year',
                               '2 years in the future': 'two_years',
                               '3 years in the future': 'three_years' }.freeze

  enum :access, { stanford: 'stanford', world: 'world', depositor_selects: 'depositor_selects' }, suffix: true
  enum :doi_option, { yes: 'yes', no: 'no', depositor_selects: 'depositor_selects' }, suffix: true
  enum :license_option, { required: 'required', depositor_selects: 'depositor_selects' }, suffix: true
  enum :custom_rights_statement_option, { no: 'no', provided: 'provided', depositor_selects: 'depositor_selects' },
       suffix: true

  # deposit_job_started_at indicates that the job is queued or running.
  # User should be "waiting" until the job is completed.
  def deposit_job_started?
    deposit_job_started_at.present?
  end

  def deposit_job_finished?
    deposit_job_started_at.nil?
  end

  def max_release_date
    duration = case release_duration
               when 'six_months'
                 6.months
               when 'one_year'
                 1.year
               when 'two_years'
                 2.years
               else
                 3.years
               end
    Time.zone.today + duration
  end

  def add_user_as_manager
    managers << user if user.present? && managers.exclude?(user)
  end
end
