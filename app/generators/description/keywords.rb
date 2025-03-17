# frozen_string_literal: true

module Generators
  class Description
    # Generates the Cocina parameters for a keywords.
    class Keywords
      def self.call(...)
        new(...).call
      end

      def initialize(keywords:)
        @keywords = keywords
      end

      def call
        keywords.map do |keyword|
          # Since keyword is either a Hash or an instance of KeywordForm,
          # we need to make it a hash of the attributes if it's a KeywordForm
          keyword = keyword.attributes if keyword.respond_to?(:attributes)
          next if keyword['text'].blank?

          keyword_params_for(keyword:)
        end.compact_blank
      end

      private

      attr_reader :keywords

      def keyword_params_for(keyword:)
        {
          value: keyword['text']
        }.tap do |keyword_hash|
          keyword_hash[:type] = keyword['cocina_type'] if keyword['cocina_type'].present?
          next if keyword['uri'].blank?

          keyword_hash[:uri] = keyword['uri']
          keyword_hash[:source] = { code: 'fast', uri: 'http://id.worldcat.org/fast/' }
        end
      end
    end
  end
end
