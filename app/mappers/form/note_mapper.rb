# frozen_string_literal: true

module Form
  # Maps notes.
  class NoteMapper
    ABSTRACT_TYPE = 'abstract'
    CITATION_TYPE = 'preferred citation'
    VERSION_IDENTIFICATION_TYPE = 'version identification'

    def self.abstract(cocina_object:)
      new(cocina_object:, type: ABSTRACT_TYPE).call
    end

    def self.citation(cocina_object:)
      new(cocina_object:, type: CITATION_TYPE).call
    end

    def self.version_identification(cocina_object:)
      new(cocina_object:, type: VERSION_IDENTIFICATION_TYPE).call
    end

    def initialize(cocina_object:, type:)
      @cocina_object = cocina_object
      @type = type
    end

    def call
      cocina_object.description.note.find { |note| note.type == type }&.value
    end

    private

    attr_reader :cocina_object, :type
  end
end
