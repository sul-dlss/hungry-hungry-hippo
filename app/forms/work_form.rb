# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  STANFORD_UNIVERSITY = 'Stanford University'

  accepts_nested_attributes_for :related_works, :publication_date, :contact_emails, :contributors,
                                :keywords, :create_date_single, :create_date_range_from, :create_date_range_to

  validate :contributor_presence, on: :deposit

  before_validation do
    self.keywords_attributes = keywords_attributes.reject(&:empty?).map(&:attributes).presence || [{}]
  end

  before_validation do
    blank_contributors = contributors_attributes.select(&:empty?)
    next if blank_contributors.empty? || blank_contributors.length == contributors_attributes.length

    self.contributors_attributes = (contributors_attributes - blank_contributors).map(&:attributes)
  end

  before_validation do
    blank_contact_emails = contact_emails_attributes.select(&:empty?)
    next if blank_contact_emails.empty?
    next if blank_contact_emails.length == contact_emails_attributes.length && works_contact_email.blank?

    self.contact_emails_attributes = (contact_emails_attributes - blank_contact_emails).map(&:attributes)
  end

  validate :content_file_count, on: :deposit

  with_options if: -> { create_date_type == 'range' } do
    validate :create_date_range_complete
    validate :create_date_range_sequence
  end

  def self.immutable_attributes
    ['druid']
  end

  attribute :druid, :string
  alias id druid

  def persisted?
    druid.present?
  end

  attribute :collection_druid, :string

  attribute :lock, :string
  attribute :content_id, :integer

  attribute :version, :integer, default: 1

  # Contact email required by collection
  attribute :works_contact_email, :string

  attribute :title, :string
  validates :title, presence: true

  attribute :abstract, :string
  validates :abstract, presence: true, on: :deposit
  before_validation do
    self.abstract = LinebreakSupport.normalize(abstract)
  end

  attribute :citation, :string

  attribute :license, :string
  validates :license, presence: true, on: :deposit

  attribute :work_type, :string
  before_validation do
    self.work_type = work_type.presence
  end
  validates :work_type, presence: true, on: :deposit

  attribute :work_subtypes, array: true, default: -> { [] }
  before_validation { work_subtypes.compact_blank! }
  validate :music_subtypes, if: -> { work_type == WorkType::MUSIC }
  validate :mixed_materials_subtypes, if: -> { work_type == WorkType::MIXED_MATERIALS }

  attribute :other_work_subtype, :string
  # Other requires a work subtype string
  validates :other_work_subtype, presence: true, if: -> { work_type == WorkType::OTHER }

  attribute :access, :string, default: 'world'
  validates :access, inclusion: { in: %w[world stanford] }

  attribute :release_option, :string, default: 'immediate'
  validates :release_option, inclusion: { in: %w[immediate delay] }

  attribute :release_date, :date
  with_options if: -> { release_option == 'delay' } do |form|
    form.validates :release_date, comparison: {
      greater_than_or_equal_to: -> { Time.zone.today },
      message: 'must be today or later' # rubocop:disable Rails/I18nLocaleTexts
    }

    form.validates :release_date, comparison: {
      less_than_or_equal_to: :max_release_date,
      message: lambda do |_, data|
        "must be on or before #{I18n.l(data[:count], format: :slashes_short)}"
      end
    }
  end
  attribute :max_release_date, :date

  attribute :custom_rights_statement, :string
  before_validation do
    self.custom_rights_statement = LinebreakSupport.normalize(custom_rights_statement)
  end

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option, inclusion: { in: %w[yes no assigned] }

  attribute :agree_to_terms, :boolean
  validates :agree_to_terms, acceptance: true, on: :deposit

  attribute :create_date_type, :string, default: 'single'
  validates :create_date_type, inclusion: { in: %w[single range] }

  attribute :whats_changing, :string
  validates :whats_changing, presence: true

  # Date the work was first persisted.
  # This is mapped to the description adminMetadata creation event.
  attribute :creation_date, :date
  # Date the latest version was deposited.
  # This is mapped to the description deposit publication event.
  attribute :deposit_publication_date, :date

  attribute :apo, :string, default: Settings.apo
  attribute :copyright, :string

  # This is used for tracking with Ahoy. It allows eventing before the form is saved.
  attribute :form_id, :string, default: -> { SecureRandom.uuid }

  def content_file_count
    return if content_id.nil? # This makes test configuration easier.

    file_count = Content.find(content_id).content_files.count
    errors.add(:content, 'must have at least one file') if file_count.zero?
    errors.add(:content, 'too many files') if file_count > Settings.file_upload.max_files
  end

  def create_date_range_complete
    return if create_date_range_from.year.present? && create_date_range_to.year.present?
    return if create_date_range_from.year.blank? && create_date_range_to.year.blank?

    errors.add(:create_date_range_from, 'must have both a start and end date')
  end

  def create_date_range_sequence
    create_date_range_from_edtf = create_date_range_from.to_date
    create_date_range_to_edtf = create_date_range_to.to_date
    return if create_date_range_from_edtf.nil? || create_date_range_to_edtf.nil?
    return if create_date_range_from_edtf <= create_date_range_to_edtf

    errors.add(:create_date_range_from, 'must be before end date')
  end

  def music_subtypes
    return if work_subtypes.intersect?(WorkType::MUSIC_TYPES)

    errors.add(:work_subtypes_music,
               "#{WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES} music term is the minimum allowed")
  end

  def mixed_materials_subtypes
    return if work_subtypes.length >= WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES

    errors.add(:work_subtypes_mixed_materials,
               "#{WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES} terms are the minimum allowed")
  end

  def contributor_presence
    return if contributors_attributes.any? { |contributor| !contributor.empty? }

    errors.add(:contributors, 'must have at least one contributor')
  end
end
