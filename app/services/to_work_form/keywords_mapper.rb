# frozen_string_literal: true

module ToWorkForm
  # Maps keywords.
  class KeywordsMapper < ToForm::BaseMapper
    def call
      return nil if cocina_object.description.subject.blank?

      cocina_object.description.subject.filter_map do |subject|
        next if subject.value.blank?

        {
          'text' => subject.value,
          'cocina_type' => subject.type.presence,
          'uri' => subject.uri.presence
        }
      end.presence
    end
  end
end
