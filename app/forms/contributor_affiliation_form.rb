# frozen_string_literal: true

# Form for a contributor affiliation
class ContributorAffiliationForm < ApplicationForm
  attribute :institution, :string
  attribute :department, :string
end
