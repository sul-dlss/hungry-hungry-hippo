# frozen_string_literal: true

module Cocina
  # Pretties a cocina object
  class Prettier
    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    # @return [Hash] the cocina object with empty values removed
    def clean
      @clean ||= perform_clean(@cocina_object.to_h)
    end

    # @return [String] the clean cocina object as a pretty JSON string
    def json
      clean.to_json
    end

    # @return [String] the clean cocina object as a pretty JSON string
    def pretty
      JSON.pretty_generate(clean)
    end

    private

    # Clean up a hash or array by removing empty values
    def perform_clean(obj)
      if obj.is_a?(Hash)
        obj.each_value { |v| perform_clean(v) }
        obj.delete_if { |_k, v| v.try(:empty?) }
      elsif obj.is_a?(Array)
        obj.each { |v| perform_clean(v) }
        obj.delete_if { |v| v.try(:empty?) }
      end
      obj
    end
  end
end
