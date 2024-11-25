# frozen_string_literal: true

# Serializer for WorkForm
class WorkFormSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(WorkForm)
  end

  def serialize(model)
    super(model.serializable_hash(include: model.class.nested_attributes))
  end

  def deserialize(hash)
    WorkForm.new(**hash.except('_aj_serialized'))
  end
end
