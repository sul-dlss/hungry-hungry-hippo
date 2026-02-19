# frozen_string_literal: true

# Form for deposit of an article by DOI
class ArticleForm < ApplicationForm
  include FilesRequired

  attribute :doi, :string
  validates :doi, presence: true
  validate :doi_exists, if: -> { doi.present? }
  validate :doi_lookup_performed, if: -> { doi_exists? }, on: :deposit

  # Tracks whether user has performed a DOI lookup
  attribute :last_doi_lookup, :string

  attribute :agree_to_terms, :boolean
  validates :agree_to_terms, acceptance: true, on: :deposit

  attribute :license, :string
  validates :license, presence: true, on: :deposit

  attribute :collection_druid, :string
  attribute :content_id, :integer

  # This is used for tracking with Ahoy. It allows eventing before the form is saved.
  attribute :form_id, :string, default: -> { SecureRandom.uuid }

  def doi_exists
    errors.add(:doi, 'not found') unless doi_exists?
  end

  def doi_exists?
    return false if doi.blank?

    CrossrefService.call(doi:)
    true
  rescue CrossrefService::NotFound
    false
  end

  def doi_lookup_performed
    errors.add(:doi, 'lookup before saving or depositing') unless lookup_performed?
  end

  def lookup_performed?
    last_doi_lookup.presence == doi.presence
  end
end
