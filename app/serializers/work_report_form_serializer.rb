# frozen_string_literal: true

# Serializer for WorkReportForm
class WorkReportFormSerializer < ApplicationSerializer
  private

  def klass
    Admin::WorkReportForm
  end
end
