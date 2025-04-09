# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps release date.
  class WorkReleaseDateMapper < BaseMapper
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
