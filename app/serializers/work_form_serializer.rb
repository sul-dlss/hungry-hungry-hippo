# frozen_string_literal: true

# Serializer for WorkForm
class WorkFormSerializer < ApplicationSerializer
  private

  def klass
    BaseWorkForm
  end
end
