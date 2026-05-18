# frozen_string_literal: true

# Base form for a Work that validates completeness.
# Completeness (as defined here) are required for Works or GitHub Repositories, but not Articles.
class CompleteBaseWorkForm < BaseWorkForm
  validate :contributor_presence, on: :deposit

  before_validation do
    non_blank_keywords = keywords.reject(&:empty?)
    next if non_blank_keywords.empty? || non_blank_keywords.length == keywords.length

    keywords.clear
    non_blank_keywords.each { |keyword| keywords << keyword }
  end

  before_validation do
    blank_contact_emails = contact_emails.select(&:empty?)
    next if blank_contact_emails.empty?
    next if blank_contact_emails.length == contact_emails.length && works_contact_email.blank?

    non_blank_contact_emails = contact_emails.reject(&:empty?)
    contact_emails.clear
    non_blank_contact_emails.each { |contact_email| contact_emails << contact_email }
  end

  validates :abstract,
            presence: { message: I18n.t('work_form.fields.abstract.validations.blank') },
            on: :deposit

  validates :license,
            presence: { message: I18n.t('work_form.fields.license.validations.blank') },
            on: :deposit

  validates :work_type, presence: { message: I18n.t('work_form.fields.work_type.validations.required') }, on: :deposit

  def contributor_presence
    return if contributors.any? { |contributor| !contributor.empty? }

    errors.add(:contributors, I18n.t('work_form.fields.contributors.validations.minimum'))
  end
end
