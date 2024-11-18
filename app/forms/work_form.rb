# frozen_string_literal: true

# Form for a Work
class WorkForm < ApplicationForm
  attribute :druid, :string
  alias id druid

  def persisted?
    druid.present?
  end

  attribute :lock, :string

  attribute :version, :integer, default: 1

  attribute :title, :string
  validates :title, presence: true

  attribute :abstract, :string
  validates :abstract, presence: true, if: :deposit?
end
