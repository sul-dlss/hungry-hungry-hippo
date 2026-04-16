# frozen_string_literal: true

# Form for a Work's shares
class WorkShareForm < ApplicationForm
  has_many :shares
end
