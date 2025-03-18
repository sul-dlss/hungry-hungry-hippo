# frozen_string_literal: true

class WorkBuilder
  # Builds release date for work from from Cocina object
  class ReleaseDateBuilder < BaseBuilder
    def call
      return { release_option: 'immediate' } if release_date.blank?

      { release_date:, release_option: 'delay' }
    end

    private

    def release_date
      @release_date ||= cocina_object.access&.embargo&.releaseDate
    end
  end
end
