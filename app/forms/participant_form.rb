# frozen_string_literal: true

# Form for collection participants
class ParticipantForm < RefactoredApplicationForm
  attribute :sunetid, :string
  attribute :name, :string
end
