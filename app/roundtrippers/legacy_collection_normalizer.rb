# Normnalizes legacy (H2) Collections to be compatible with H3 cocina.
class LegacyCollectionNormalizer
  def self.call(...)
    new(...).call
  end

  def initialize(cocina_object:)
    @cocina_object = cocina_object
  end

  def call
    normalize_access
    normalize_description

    cocina_attrs[:label] = Cocina::Parser.title_for(cocina_object:)

    norm_cocina_object = Cocina::Models.build(cocina_attrs)
    Cocina::Models.with_metadata(norm_cocina_object, cocina_object.lock, created: cocina_object.created,
                                                                         modified: cocina_object.modified)
  end

  private

  attr_reader :cocina_object

  def cocina_attrs
    @cocina_attrs ||= Cocina::Models.without_metadata(cocina_object).to_h
  end

  def normalize_access
    cocina_attrs[:access].delete(:copyright)
    cocina_attrs[:access].delete(:useAndReproductionStatement)
    cocina_attrs[:access].delete(:license)
  end

  def normalize_description
    cocina_attrs[:description].delete(:form)
    cocina_attrs[:description].delete(:contributor)
  end
end
