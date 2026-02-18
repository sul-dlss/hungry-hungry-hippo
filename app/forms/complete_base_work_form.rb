# frozen_string_literal: true

# Base form for a Work that validates completeness.
# Completeness (as defined here) are required for Works or GitHub Repositories, but not Articles.
class CompleteBaseWorkForm < BaseWorkForm
  validate :contributor_presence, on: :deposit

  before_validation do
    blank_keywords = keywords.select(&:empty?)
    next if blank_keywords.empty? || blank_keywords.length == keywords.length

    self.keywords = keywords - blank_keywords
  end

  before_validation do
    blank_contributors = contributors.select(&:empty?)
    next if blank_contributors.empty? || blank_contributors.length == contributors.length

    self.contributors = contributors - blank_contributors
  end

  before_validation do
    blank_contact_emails = contact_emails.select(&:empty?)
    next if blank_contact_emails.empty?
    next if blank_contact_emails.length == contact_emails.length && works_contact_email.blank?

    self.contact_emails = (contact_emails - blank_contact_emails)
  end

  validates :abstract, presence: true, on: :deposit

  validates :license, presence: true, on: :deposit

  validates :work_type, presence: true, on: :deposit

  def contributor_presence
    return if contributors.any? { |contributor| !contributor.empty? }

    errors.add(:contributors, 'must have at least one contributor')
  end
end
