# frozen_string_literal: true

# Form for deposit of an article by DOI
class ArticleForm < ApplicationForm
  include FilesRequired

  # if the user enters a DOI as the identifier, both attributes will be the same,
  # else the identifier attribute will be what they entered, and DOI will be what was looked up
  attribute :doi, :string
  validates :doi, presence: true
  attribute :identifier, :string
  validates :identifier, presence: true

  validate :doi_article, if: -> { identifier.present? }
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
    if identifier.present?
      identifier.strip!

      # already looks like a DOI? no need to do an extra lookup; else lookup in Pubmed
      # DOI identification could be more robust if needed using regex, e.g. https://www.crossref.org/blog/dois-and-matching-regular-expressions/
      self.doi = if identifier.include?('/')
                   identifier
                 else
                   PubmedService.call(search: identifier)
                 end
      results = CrossrefService.call(doi:)
      @doi_has_title = results[:title].present?
      @doi_found = true
      @doi_journal_article = true
    end
  rescue PubmedService::NotFound, PubmedService::Error, CrossrefService::NotFound
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

  def doi_has_title?
    @doi_has_title
  end

  def lookup_performed?
    last_doi_lookup.presence == doi.presence
  end

  private

  def doi_article
    return errors.add(:identifier, 'identifier was not found') unless doi_found?

    return errors.add(:identifier, 'identifier is not a journal article') unless doi_journal_article?

    errors.add(:identifier, 'identifier does not have a title') unless doi_has_title?
  end

  def doi_ok?
    return false if doi.blank?

    doi_found? && doi_journal_article? && doi_has_title?
  end

  def doi_lookup_performed
    errors.add(:identifier, 'lookup before saving or depositing') unless lookup_performed?
  end
end
