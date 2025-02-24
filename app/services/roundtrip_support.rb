# frozen_string_literal: true

# Support methods for roundtrip validation.
class RoundtripSupport
  def self.normalize_cocina_object(cocina_object:)
    # Remove created_at and updated_at from the original cocina object
    lock = cocina_object&.lock
    norm_cocina_object = Cocina::Models.without_metadata(cocina_object)
    norm_cocina_object = norm_cocina_object.new(cocinaVersion: Cocina::Models::VERSION)

    Cocina::Models.with_metadata(norm_cocina_object, lock)
  end

  # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina_object
  # @return [Boolean] true if the provided cocina object is the same as a cocina object retrieved from SDR.
  def self.changed?(cocina_object:)
    original_cocina_object = Sdr::Repository.find(druid: cocina_object.externalIdentifier)
    cocina_object != normalize_cocina_object(cocina_object: original_cocina_object)
  end

  def self.notify_error(original_cocina_object:, roundtripped_cocina_object:) # rubocop:disable Metrics/AbcSize
    original_prettier ||= Cocina::Prettier.new(cocina_object: original_cocina_object)
    roundtripped_prettier ||= Cocina::Prettier.new(cocina_object: roundtripped_cocina_object)
    Honeybadger.notify('Roundtrip failed',
                       context: { original: original_prettier.json, roundtripped: roundtripped_prettier.json })
    # Pretty for dev and test makes reading the logs easier. Not pretty for production makes grepping easier.
    Rails.logger.info('Roundtrip failed. Original: ' \
                      "#{Rails.env.production? ? original_prettier.json : original_prettier.pretty}")
    Rails.logger.info('Roundtripped: ' \
                      "#{Rails.env.production? ? roundtripped_prettier.json : roundtripped_prettier.pretty}")
  end
end
