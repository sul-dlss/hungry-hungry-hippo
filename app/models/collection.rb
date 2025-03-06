# frozen_string_literal: true

# Model for a collection.
# Note that this model does not contain any cocina data.
class Collection < ApplicationRecord
  include DepositStateMachine

  belongs_to :user
  has_many :works, dependent: :destroy

  has_many :collection_depositors, dependent: :destroy
  has_many :collection_managers, dependent: :destroy
  has_many :collection_reviewers, dependent: :destroy
  has_many :depositors, through: :collection_depositors, source: :user
  has_many :managers, through: :collection_managers, source: :user
  has_many :reviewers, through: :collection_reviewers, source: :user

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

  def review_enabled?
    review_enabled
  end

  def reviewers_and_managers
    (reviewers + managers).uniq
  end

  def first_version?
    version == 1
  end

  def to_param
    druid
  end
end
