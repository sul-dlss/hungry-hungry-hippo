# frozen_string_literal: true

# Serializer for WorkForm
class WorkFormSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(WorkForm)
  end

  def serialize(model)
    super(model.as_json)
  end

  def deserialize(hash)
    work_form = WorkForm.new
    work_form.attributes = hash.except('_aj_serialized')
    work_form
  end
end
