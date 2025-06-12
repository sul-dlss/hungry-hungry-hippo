# frozen_string_literal: true

# Serializer for WorkReportForm
class WorkReportFormSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(Admin::WorkReportForm)
  end

  def serialize(form)
    super(form.serializable_hash)
  end

  def deserialize(hash)
    Admin::WorkReportForm.new(**hash.except('_aj_serialized'))
  end
end
