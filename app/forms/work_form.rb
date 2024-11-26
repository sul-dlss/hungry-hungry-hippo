# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  accepts_nested_attributes_for :related_links

  def self.immutable_attributes
    ['druid']
  end

  attribute :druid, :string
  alias id druid

  def persisted?
    druid.present?
  end

  attribute :collection_id, :integer

  attribute :lock, :string
  attribute :content_id, :integer

  attribute :version, :integer, default: 1

  attribute :title, :string
  validates :title, presence: true

  attribute :abstract, :string
  validates :abstract, presence: true, if: :deposit?

  attribute :license, :string
  validates :license, presence: true, if: :deposit?

  def license_label
    return unless license

    yaml = YAML.load_file('config/licenses.yml')
    selected_license = yaml.select { |_, v| v['uri'] == license }
    selected_license.keys.first
  end
end
