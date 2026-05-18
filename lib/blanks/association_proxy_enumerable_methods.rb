# frozen_string_literal: true

module Blanks
  # Extends Blanks::AssociationProxy with common collection methods so callers
  # don't need to unwrap via `to_a` for simple queries and ordering.
  module AssociationProxyEnumerableMethods
    def any?(&block)
      return super() unless block

      to_a.any?(&block)
    end

    delegate :reverse, to: :to_a
  end
end
