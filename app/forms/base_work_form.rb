# frozen_string_literal: true

# Base form for a Work.
# All attributes should be added here (instead of subclasses) so that mappers
# don't need to know about subclasses.
class BaseWorkForm < ApplicationForm # rubocop:disable Metrics/ClassLength
  STANFORD_UNIVERSITY = 'Stanford University'
  ARTICLE_VERSION_IDENTIFICATION_OPTIONS = [
    'Author submitted version',
    'Author accepted version',
    'Final published version of the work'
  ].freeze

  accepts_nested_attributes_for :related_works, :publication_date, :contact_emails, :contributors,
                                :keywords, :create_date_single, :create_date_range_from, :create_date_range_to

  # At least one contributor is required.
  before_validation do
    blank_contributors = contributors.select(&:empty?)
    next if blank_contributors.empty? || blank_contributors.length == contributors.length

    self.contributors = contributors - blank_contributors
  end

  with_options if: -> { create_date_type == 'range' && create_date_range_from.valid? && create_date_range_to.valid? } do
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
  validates :title, presence: { message: I18n.t('work_form.fields.title.validations.blank') }

  attribute :abstract, :string
  validates :abstract,
            length: {
              maximum: Settings.abstract_maximum_length,
              message: lambda do |_, data|
                I18n.t('work_form.fields.abstract.validations.too_long', count: data[:count])
              end
            }
  before_validation do
    self.abstract = LinebreakSupport.normalize(abstract)
  end

  attribute :citation, :string

  attribute :license, :string

  attribute :work_type, :string
  before_validation do
    self.work_type = work_type.presence
  end

  attribute :work_subtypes, array: true, default: -> { [] }
  before_validation { work_subtypes.compact_blank! }
  validate :music_subtypes, if: -> { work_type == WorkType::MUSIC }
  validate :mixed_materials_subtypes, if: -> { work_type == WorkType::MIXED_MATERIALS }

  attribute :other_work_subtype, :string
  # Other requires a work subtype string
  validates :other_work_subtype,
            presence: { message: I18n.t('work_form.fields.other_work_subtype.validations.blank') },
            if: -> { work_type == WorkType::OTHER }

  # For Articles
  attribute :article_version_identification, :string
  validates :article_version_identification,
            inclusion: {
              in: ARTICLE_VERSION_IDENTIFICATION_OPTIONS,
              message: I18n.t('work_form.fields.article_version_identification.validations.inclusion')
            },
            allow_nil: true

  attribute :access, :string, default: 'world'
  validates :access,
            inclusion: {
              in: %w[world stanford],
              message: I18n.t('work_form.fields.access.validations.inclusion')
            }

  attribute :release_option, :string, default: 'immediate'
  validates :release_option,
            inclusion: {
              in: %w[immediate delay],
              message: I18n.t('work_form.fields.release_option.validations.inclusion')
            }

  attribute :release_date, :date
  with_options if: -> { release_option == 'delay' } do |form|
    form.validates :release_date, comparison: {
      greater_than_or_equal_to: -> { Time.zone.today },
      message: lambda do |record, _data|
        I18n.t('work_form.fields.release_date.validations.today_or_later',
               date: I18n.l(record.max_release_date, format: :slashes_short))
      end
    }

    form.validates :release_date, comparison: {
      less_than_or_equal_to: :max_release_date,
      message: lambda do |_, data|
        I18n.t('work_form.fields.release_date.validations.on_or_before',
               date: I18n.l(data[:count], format: :slashes_short))
      end
    }
  end
  attribute :max_release_date, :date

  attribute :custom_rights_statement, :string
  before_validation do
    self.custom_rights_statement = LinebreakSupport.normalize(custom_rights_statement)
  end

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option,
            inclusion: {
              in: %w[yes no assigned],
              message: I18n.t('work_form.fields.doi_option.validations.inclusion')
            }

  attribute :agree_to_terms, :boolean
  validates :agree_to_terms,
            acceptance: { message: I18n.t('work_form.fields.agree_to_terms.validations.accepted') },
            on: :deposit

  attribute :create_date_type, :string, default: 'single'
  validates :create_date_type,
            inclusion: {
              in: %w[single range],
              message: I18n.t('work_form.fields.create_date_type.validations.inclusion')
            }

  # Reset the opposite create date type when switching between single and range
  # to prevent validation errors from the hidden form fields.
  before_validation do
    if create_date_type == 'range'
      self.create_date_single = DateForm.new
    else
      self.create_date_range_from = DateForm.new
      self.create_date_range_to = DateForm.new
    end
  end

  attribute :whats_changing, :string
  validates :whats_changing, presence: { message: I18n.t('work_form.fields.whats_changing.validations.blank') }

  # Date the work was first persisted.
  # This is mapped to the description adminMetadata creation event.
  attribute :creation_date, :date
  # Date the latest version was deposited.
  # This is mapped to the description deposit publication event.
  attribute :deposit_publication_date, :date

  attribute :apo, :string, default: Settings.apo
  attribute :copyright, :string

  # Used for GithubRepositoryWorkForm
  attribute :github_deposit_enabled, :boolean

  # This is used for tracking with Ahoy. It allows eventing before the form is saved.
  attribute :form_id, :string, default: -> { SecureRandom.uuid }

  def create_date_range_complete
    return if create_date_range_from.year.present? && create_date_range_to.year.present?
    return if create_date_range_from.year.blank? && create_date_range_to.year.blank?

    errors.add(:create_date_range_from, I18n.t('work_form.fields.create_date_range_from.validations.complete'))
  end

  def create_date_range_sequence
    create_date_range_from_edtf = create_date_range_from.to_date
    create_date_range_to_edtf = create_date_range_to.to_date
    return if create_date_range_from_edtf.nil? || create_date_range_to_edtf.nil?
    return if create_date_range_from_edtf <= create_date_range_to_edtf

    errors.add(:create_date_range_from, I18n.t('work_form.fields.create_date_range_from.validations.sequence'))
  end

  def music_subtypes
    return if work_subtypes.intersect?(WorkType::MUSIC_TYPES)

    errors.add(:work_subtypes_music,
               I18n.t('work_form.fields.work_subtypes_music.validations.minimum',
                      count: WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES))
  end

  def mixed_materials_subtypes
    return if work_subtypes.length >= WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES

    errors.add(:work_subtypes_mixed_materials,
               I18n.t('work_form.fields.work_subtypes_mixed_materials.validations.minimum',
                      count: WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES))
  end

  def contributor_presence
    return if contributors.any? { |contributor| !contributor.empty? }

    errors.add(:contributors, I18n.t('work_form.fields.contributors.validations.minimum'))
  end

  def locales_key
    'work_form'
  end
end
