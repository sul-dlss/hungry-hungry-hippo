# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  STANFORD_UNIVERSITY = 'Stanford University'

  accepts_nested_attributes_for :related_links, :related_works, :publication_date, :contact_emails, :contributors,
                                :keywords, :create_date_single, :create_date_range_from, :create_date_range_to

  validate :content_file_presence, on: :deposit
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

  attribute :title, :string
  validates :title, presence: true

  attribute :abstract, :string
  validates :abstract, presence: true, on: :deposit
  before_validation ->(work_form) { work_form.abstract = LinebreakSupport.normalize(work_form.abstract) }

  attribute :citation, :string
  attribute :auto_generate_citation, :boolean
  validates :citation, presence: true, if: -> { auto_generate_citation == false }

  attribute :license, :string

  attribute :work_type, :string
  validates :work_type, presence: true, on: :deposit

  attribute :work_subtypes, array: true, default: -> { [] }
  before_validation ->(work_form) { work_form.work_subtypes.compact_blank! }
  validate :correct_work_subtype_length

  attribute :other_work_subtype, :string
  # Other requires a work subtype string
  validates :other_work_subtype, presence: true, if: -> { work_type == WorkType::OTHER }

  attribute :access, :string, default: 'world'
  validates :access, inclusion: { in: %w[world stanford] }

  attribute :release_option, :string, default: 'immediate'
  validates :release_option, inclusion: { in: %w[immediate delay] }

  attribute :release_date, :date
  with_options if: -> { release_option == 'delay' } do |form|
    form.validates :release_date, presence: true
    form.validates :release_date, comparison: {
      greater_than_or_equal_to: -> { Time.zone.today },
      message: 'must be today or later' # rubocop:disable Rails/I18nLocaleTexts
    }

    form.validates :release_date, comparison: {
      less_than_or_equal_to: :max_release_date,
      message: 'must be on or before %<count>s' # rubocop:disable Rails/I18nLocaleTexts
    }
  end

  attribute :custom_rights_statement, :string

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option, inclusion: { in: %w[yes no assigned] }

  attribute :agree_to_terms, :boolean
  validates :agree_to_terms, acceptance: true, on: :deposit

  attribute :create_date_type, :string, default: 'single'
  validates :create_date_type, inclusion: { in: %w[single range] }

  attribute :whats_changing, :string
  validates :whats_changing, presence: true, on: :deposit, if: :persisted?

  def content_file_presence
    return if content_id.nil? # This makes test configuration easier.
    return if Content.find(content_id).content_files.exists?

    errors.add(:content, 'must have at least one file')
  end

  def max_release_date
    Collection.find_by(druid: collection_druid).max_release_date
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

  def correct_work_subtype_length
    # Doing custom validation because need to set custom error keys.
    length = work_subtypes.length
    if work_type == WorkType::MUSIC && length < WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES
      errors.add(:work_subtypes_music,
                 "#{WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES} term is the minimum allowed")
    elsif work_type == WorkType::MIXED_MATERIALS && length < WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES
      errors.add(:work_subtypes_mixed_materials,
                 "#{WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES} terms are the minimum allowed")
    end
  end
end
