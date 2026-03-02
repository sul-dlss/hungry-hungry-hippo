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

  attribute :article_version_identification, :string
  validates :article_version_identification, presence: true, on: :deposit

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
    use_full_form_message = 'You will need to use the "Deposit to this collection" button on the dashboard or ' \
                            'collection page to deposit this work.'

    unless doi_found?
      return errors.add(:identifier,
                        "Unable to retrieve metadata for this DOI/PMCID. #{use_full_form_message}")
    end

    unless doi_journal_article?
      return errors.add(:identifier,
                        "The metadata for this identifier indicates it is not a journal article. #{use_full_form_message}") # rubocop:disable Layout/LineLength
    end

    return if doi_has_title?

    errors.add(:identifier,
               "The metadata for this identifier does not include a title. #{use_full_form_message}")
  end

  def doi_ok?
    return false if doi.blank?

    doi_found? && doi_journal_article? && doi_has_title?
  end

  def doi_lookup_performed
    errors.add(:identifier, 'Look up before editing or depositing') unless lookup_performed?
  end
end
