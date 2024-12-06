# frozen_string_literal: true

# Helpers for working with Cocina objects
class CocinaSupport
  def self.title_for(cocina_object:)
    cocina_object.description.title.first.value
  end

  # Maps the value from the accessContact field in the Cocina::DescriptiveAccessMetadata object.
  # to the email value for a contact_email in the WorkForm
  # @param [Cocina::Models::DRO] cocina_object
  # @return [Array<Hash>, Nil] with keys for email
  def self.contact_emails_for(cocina_object:)
    return nil if cocina_object.description.access.blank?

    cocina_object.description.access.accessContact.filter_map do |access_contact|
      next if access_contact.value.blank?

      { 'email' => access_contact[:value] }
    end.presence
  end

  def self.related_links_for(cocina_object:) # rubocop:disable Metrics/AbcSize
    return nil if cocina_object.description.relatedResource.blank?

    cocina_object.description.relatedResource.filter_map do |related_resource|
      next if related_resource.access&.url.blank?

      { 'url' => related_resource.access.url.first[:value], 'text' => related_resource.title.first&.[](:value) }
    end.presence
  end

  def self.related_works_for(cocina_object:)
    return nil if cocina_object.description.relatedResource.blank?

    cocina_object.description.relatedResource.map do |related_resource|
      citation, identifier = related_work_values_from(related_resource)

      next if citation.blank? && identifier.blank?

      {
        'citation' => citation,
        'identifier' => identifier,
        'relationship' => related_resource.type,
        'use_citation' => citation.present?
      }
    end.compact_blank.presence
  end

  def self.abstract_for(cocina_object:)
    cocina_object.description.note.find { |note| note.type == 'abstract' }&.value
  end

  def self.pretty(cocina_object:)
    JSON.pretty_generate(clean(cocina_object.to_h))
  end

  def self.related_work_values_from(related_resource) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return [] if RelatedWorkForm::RELATIONSHIP_TYPES.exclude?(related_resource.type)

    if related_resource.note&.first&.[](:type) == 'preferred citation'
      return [related_resource.note&.first&.[](:value), nil]
    end

    return [nil, related_resource.identifier&.first&.[](:uri)] if related_resource.identifier&.first&.[](:uri).present?

    []
  end
  private_class_method :related_work_values_from

  # Clean up a hash or array by removing empty values
  def self.clean(obj)
    if obj.is_a?(Hash)
      obj.each_value { |v| clean(v) }
      obj.delete_if { |_k, v| v.try(:empty?) }
    elsif obj.is_a?(Array)
      obj.each { |v| clean(v) }
      obj.delete_if { |v| v.try(:empty?) }
    end
    obj
  end
  private_class_method :clean

  # Updates version and lock for the provided Cocina object.
  def self.update_version_and_lock(cocina_object:, version:, lock:)
    params = Cocina::Models.without_metadata(cocina_object).to_h
    params['version'] = version
    params[:structural][:contains].each do |file_set_params|
      file_set_params[:version] = version
      file_set_params[:structural][:contains].each do |file_params|
        file_params[:version] = version
      end
    end
    Cocina::Models.with_metadata(Cocina::Models.build(params), lock)
  end

  def self.collection_druid_for(cocina_object:)
    cocina_object.structural.isMemberOf.first
  end

  # Returns the event date parsed from an EDTF date value.
  # @param [Cocina::Models::DRO] cocina_object
  # @param [String] type, e.g., 'publication'
  # @return [Hash, Nil] with keys for year, month, and day
  def self.event_date_for(cocina_object:, type:) # rubocop:disable Metrics/AbcSize
    event = cocina_object.description.event.find { |e| e.type == type }
    return if event.blank?

    cocina_date = event.date.first
    return unless cocina_date.encoding&.code == 'edtf'

    date = Date.edtf!(cocina_date.value)
    # Using count of dashes to determine the date parts present
    dash_count = cocina_date.value.count('-')
    { year: date.year }.tap do |date_params|
      date_params[:month] = date.month if dash_count >= 1
      date_params[:day] = date.day if dash_count == 2
    end
  end
end
