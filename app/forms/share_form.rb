# frozen_string_literal: true

# Form for a Share
class ShareForm < ParticipantForm
  attribute :permission, :string, default: 'view'
end
