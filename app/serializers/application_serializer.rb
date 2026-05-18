# frozen_string_literal: true

# Base application serializer
class ApplicationSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(klass)
  end

  def serialize(model)
    payload = if model.respond_to?(:serializable_hash)
                model.serializable_hash
              elsif model.respond_to?(:attributes)
                model.attributes
              else
                raise TypeError, "Cannot serialize #{model.class}: expected serializable_hash or attributes"
              end

    super(payload)
  end

  def deserialize(hash)
    klass.new(**hash.except('_aj_serialized'))
  end

  private

  def klass
    raise NotImplementedError, 'Override this in any subclasses'
  end
end
