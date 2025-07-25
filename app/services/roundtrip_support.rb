# frozen_string_literal: true

# Support methods for roundtrip validation.
class RoundtripSupport
  def self.normalize_cocina_object(cocina_object:)
    # Remove created_at and updated_at from the original cocina object
    lock = cocina_object&.lock
    norm_cocina_object = Cocina::Models.without_metadata(cocina_object)
    other_attrs = if cocina_object.dro?
                    { structural: normalize_structural_attrs(structural_attrs: cocina_object.structural.to_h,
                                                             version: cocina_object.version) }
                  else
                    {}
                  end
    norm_cocina_object = norm_cocina_object.new(cocinaVersion: Cocina::Models::VERSION, **other_attrs)

    Cocina::Models.with_metadata(norm_cocina_object, lock)
  end

  def self.normalize_structural_attrs(structural_attrs:, version:)
    Array(structural_attrs[:contains]).each do |fileset_attrs|
      fileset_attrs[:version] = version
      Array(fileset_attrs.dig(:structural, :contains)).each do |file_atts|
        file_atts[:version] = version
      end
    end
    structural_attrs
  end
  private_class_method :normalize_structural_attrs

  # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina_object
  # @return [Boolean] true if the provided cocina object is the same as a cocina object retrieved from SDR.
  def self.changed?(cocina_object:, original_cocina_object: nil)
    original_cocina_object ||= Sdr::Repository.find(druid: cocina_object.externalIdentifier)
    cocina_object != normalize_cocina_object(cocina_object: original_cocina_object)
  end

  def self.notify_error(original_cocina_object:, roundtripped_cocina_object:) # rubocop:disable Metrics/AbcSize
    original_prettier ||= Cocina::Prettier.new(cocina_object: original_cocina_object)
    roundtripped_prettier ||= Cocina::Prettier.new(cocina_object: roundtripped_cocina_object)
    Honeybadger.notify('Roundtrip failed',
                       context: { original: original_prettier.json, roundtripped: roundtripped_prettier.json })
    # Pretty for dev and test makes reading the logs easier.
    unless Rails.env.production?
      Rails.logger.info("Roundtrip failed. Pretty original: #{original_prettier.pretty}")
      Rails.logger.info("Pretty roundtripped: #{roundtripped_prettier.pretty}")
    end
    Rails.logger.info("Roundtrip failed. Original: #{original_prettier.json}")
    Rails.logger.info("Roundtripped: #{roundtripped_prettier.json}")
  end

  def self.notify_validation_error(error:)
    Rails.logger.error("Roundtripping validation error: #{error.message}")
  end
end
