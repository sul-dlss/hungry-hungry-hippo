# frozen_string_literal: true

module ToWorkForm
  # Maps release date.
  class ReleaseDateMapper < ToForm::BaseMapper
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
