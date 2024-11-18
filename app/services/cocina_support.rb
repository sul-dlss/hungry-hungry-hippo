# frozen_string_literal: true

# Helpers for working with Cocina objects
class CocinaSupport
  def self.title_for(cocina_object:)
    cocina_object.description.title.first.value
  end

  def self.pretty(cocina_object:)
    JSON.pretty_generate(clean(cocina_object.to_h))
  end

  # Clean up a hash or array by removing empty values
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.clean(obj)
    if obj.is_a?(Hash)
      obj.each_value { |v| clean(v) }
      obj.delete_if { |_k, v| v.respond_to?(:empty?) && v.empty? }
    elsif obj.is_a?(Array)
      obj.each { |v| clean(v) }
      obj.delete_if { |v| v.respond_to?(:empty?) && v.empty? }
    end
    obj
  end
  private_class_method :clean
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # Updates version and lock for the provided Cocina object.
  def self.update_version_and_lock(cocina_object:, version:, lock:)
    params = Cocina::Models.without_metadata(cocina_object).to_h
    params['version'] = version
    # params[:structural][:contains].each do |file_set_params|
    #   file_set_params[:version] = version
    #   file_set_params[:structural][:contains].each do |file_params|
    #     file_params[:version] = version
    #   end
    # end
    Cocina::Models.with_metadata(Cocina::Models.build(params), lock)
  end
end
