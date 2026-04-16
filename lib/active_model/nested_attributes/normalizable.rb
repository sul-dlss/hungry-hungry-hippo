# frozen_string_literal: true

module ActiveModel
  module NestedAttributes
    # Internal normalization helpers shared by nested-attributes mixins.
    #
    # This module extracts payload normalization concerns so callers can reuse
    # the same array/hash normalization semantics for repeatable nested
    # associations.
    #
    # @see ActiveModel::NestedAttributes::Nestable
    # @see ActiveModel::NestedAttributes::Seedable
    module Normalizable
      private

      # Normalizes collection payloads for repeatable hydration.
      #
      # Supports arrays and hash-style payloads (for example Rails-style indexed
      # nested params).
      #
      # @param params [Array<Hash>, Hash, nil] incoming nested collection payload
      # @return [Array<Hash>] compacted array of nested attribute hashes
      #
      # @example Hash-style nested params
      #   normalize_nested_collection_params({ "0" => { a: 1 }, "1" => { a: 2 } })
      #   # => [{ a: 1 }, { a: 2 }]
      #
      # @example Array-style nested params
      #   normalize_nested_collection_params([{ a: 1 }, nil, { a: 2 }])
      #   # => [{ a: 1 }, { a: 2 }]
      # @api private
      def normalize_nested_collection_params(params)
        return [] if params.nil?

        raw_values = params.respond_to?(:values) ? params.values : params
        Array(raw_values).compact
      end
    end
  end
end
