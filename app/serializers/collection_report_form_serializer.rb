# frozen_string_literal: true

# Serializer for CollectionReportForm
class CollectionReportFormSerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a?(Admin::CollectionReportForm)
  end

  def serialize(form)
    super(form.serializable_hash)
  end

  def deserialize(hash)
    Admin::CollectionReportForm.new(**hash.except('_aj_serialized'))
  end
end
