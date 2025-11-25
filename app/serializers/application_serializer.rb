# frozen_string_literal: true

# Base application serializer
class ApplicationSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(klass)
  end

  def serialize(model)
    super(model.serializable_hash)
  end

  def deserialize(hash)
    klass.new(**hash.except('_aj_serialized'))
  end

  private

  def klass
    raise NotImplementedError, 'Override this in any subclasses'
  end
end
