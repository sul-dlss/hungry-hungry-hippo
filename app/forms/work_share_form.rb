# frozen_string_literal: true

# Form for a Work's shares
class WorkShareForm < ApplicationForm
  accepts_nested_attributes_for :shares
end
