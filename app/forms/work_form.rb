# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :related_works, :publication_date, :contact_emails, :authors, :keywords

  validate :content_file_presence, on: :deposit

  def self.immutable_attributes
    ['druid']
  end

  def self.licenses
    @licenses ||= YAML.load_file('config/licenses.yml')
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

  attribute :citation, :string
  attribute :auto_generate_citation, :boolean
  validates :citation, presence: true, if: -> { auto_generate_citation == false }

  attribute :license, :string
  validates :license, presence: true, on: :deposit

  attribute :work_type, :string
  validates :work_type, presence: true, on: :deposit

  attribute :work_subtypes, array: true, default: -> { [] }
  # Music and mixed materials have a minimum number of subtypes required
  validates :work_subtypes, length: { minimum: WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES,
                                      too_short: '%<count>s term is the minimum allowed' },
                            if: lambda {
                              work_type == WorkType::MUSIC
                            }
  validates :work_subtypes, length: { minimum: WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES,
                                      too_short: '%<count>s terms is the minimum allowed' },
                            if: lambda {
                              work_type == WorkType::MIXED_MATERIALS
                            }

  attribute :other_work_subtype, :string
  # Other requires a work subtype string
  validates :other_work_subtype, presence: true, if: -> { work_type == WorkType::OTHER }

  def content_file_presence
    return if content_id.nil? # This makes test configuration easier.
    return if Content.find(content_id).content_files.exists?

    errors.add(:content, 'must have at least one file')
  end
end
