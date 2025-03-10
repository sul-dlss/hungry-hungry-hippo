# frozen_string_literal: true

# Form for collection participants
class ParticipantForm < ApplicationForm
  attribute :sunetid, :string
  attribute :name, :string

  def empty?
    sunetid.blank? && name.blank?
  end
end
