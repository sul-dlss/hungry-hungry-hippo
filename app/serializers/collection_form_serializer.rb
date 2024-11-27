# frozen_string_literal: true

# Serializer for CollectionForm
class CollectionFormSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(CollectionForm)
  end

  def serialize(model)
    super(model.serializable_hash(include: model.class.nested_attributes))
  end

  def deserialize(hash)
    CollectionForm.new(**hash.except('_aj_serialized'))
  end
end
