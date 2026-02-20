# frozen_string_literal: true

# Form for deposit of an article by DOI
class ArticleForm < ApplicationForm
  include FilesRequired

  attribute :doi, :string
  validates :doi, presence: true
  validate :doi_exists_and_article, if: -> { doi.present? }
  validate :doi_lookup_performed, if: -> { doi_ok? }, on: :deposit

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

  before_validation do
    if doi.present?
      CrossrefService.call(doi:)
      @doi_found = true
      @doi_journal_article = true
    end
  rescue CrossrefService::NotFound
    @doi_found = false
  rescue CrossrefService::NotJournalArticle
    @doi_found = true
    @doi_journal_article = false
  end

  def doi_found?
    @doi_found
  end

  def doi_journal_article?
    @doi_journal_article
  end

  def lookup_performed?
    last_doi_lookup.presence == doi.presence
  end

  private

  def doi_exists_and_article
    return errors.add(:doi, 'not found') unless doi_found?

    errors.add(:doi, 'is not a journal article') unless doi_journal_article?
  end

  def doi_ok?
    return false if doi.blank?

    doi_found? && doi_journal_article?
  end

  def doi_lookup_performed
    errors.add(:doi, 'lookup before saving or depositing') unless lookup_performed?
  end
end
