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

  def self.keywords_for(cocina_object:)
    return nil if cocina_object.description.subject.blank?

    cocina_object.description.subject.filter_map do |subject|
      next if subject.value.blank?

      {
        'text' => subject.value,
        'cocina_type' => subject.type.presence,
        'uri' => subject.uri.presence
      }
    end.presence
  end

  # Maps the value from the contributor field in the cocina object to the author attributes
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.authors_for(cocina_object:)
    return nil if cocina_object.description.contributor.blank?

    cocina_object.description.contributor.filter_map do |contributor|
      full_name = contributor.name.first&.structuredValue
      { 'first_name' => full_name.find { |name| name.type == 'forename' }&.value,
        'last_name' => full_name.find { |name| name.type == 'surname' }&.value,
        'role_type' => contributor.type,
        'person_role' => (contributor.role.first.value.sub(' ', '_') if contributor.type == 'person'),
        'organization_role' => (contributor.role.first.value.sub(' ', '_') if contributor.type == 'organization'),
        'organization_name' => (contributor.name.first.value if contributor.type == 'organization'),
        'orcid' => orcid_for(contributor:),
        'with_orcid' => contributor.identifier&.find { |id| id.type == 'ORCID' }.present? }
    end.presence
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

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

  def self.citation_for(cocina_object:)
    cocina_object.description.note.find { |note| note.type == 'preferred citation' }&.value
  end

  # @return [Array<String,Array<String>>] work_type, work_subtypes
  def self.work_type_and_subtypes_for(cocina_object:)
    self_deposit_values = self_deposit_form_for(cocina_object:)&.structuredValue || []
    work_type = self_deposit_values.find { |value| value[:type] == 'type' }&.value
    work_subtypes = self_deposit_values.filter_map { |value| value[:type] == 'subtype' && value.value }
    [work_type, work_subtypes]
  end

  # @return [Cocina::Models::DescriptiveValue] descriptive value for Stanford self-deposit resource types
  def self.self_deposit_form_for(cocina_object:)
    cocina_object.description.form.find do |form|
      form&.source&.value == ToCocina::Work::TypesMapper::RESOURCE_TYPE_SOURCE_LABEL
    end
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
    if params[:structural].present?
      params[:structural][:contains].each do |file_set_params|
        file_set_params[:version] = version
        file_set_params[:structural][:contains].each do |file_params|
          file_params[:version] = version
        end
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

  def self.orcid_for(contributor:)
    contributor.identifier&.find { |id| id.type == 'ORCID' }&.value&.presence
  end

  def self.access_for(cocina_object:)
    # When there is an embargo, the embargo view is the access view.
    cocina_object.access&.embargo&.view || cocina_object.access.view
  end

  def self.license_for(cocina_object:)
    cocina_object.access.license
  end

  def self.release_date_for(cocina_object:)
    cocina_object.access&.embargo&.releaseDate
  end

  def self.use_reproduction_statement_for(cocina_object:)
    cocina_object.access.useAndReproductionStatement
  end
end
