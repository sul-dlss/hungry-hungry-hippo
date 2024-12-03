# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :related_works

  def initialize(params = {})
    # TODO: Extract nested form handling. See https://github.com/sul-dlss/hungry-hungry-hippo/issues/218
    @publication_date = DateForm.new
    super
  end

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
  validates :abstract, presence: true, if: :deposit?

  attribute :license, :string
  validates :license, presence: true, if: :deposit?

  # Shorter license label for the show page
  def license_label
    return unless license

    selected_license = WorkForm.licenses.select { |_, v| v['uri'] == license }
    selected_license.keys.first
  end

  # TODO: Extract nested form handling. See https://github.com/sul-dlss/hungry-hungry-hippo/issues/218
  attr_accessor :publication_date

  validate :publication_date_is_valid

  def publication_date_attributes=(attributes)
    @publication_date = DateForm.new(attributes)
  end

  def publication_date_is_valid
    return if publication_date.valid?

    publication_date.errors.each do |error|
      errors.add("publication_date.#{error.attribute}", error.message)
    end
  end
end
