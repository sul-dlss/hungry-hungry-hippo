# frozen_string_literal: true

# Imports a collection from a JSON export from H2.
class CollectionImporter
  def self.call(...)
    new(...).call
  end

  def initialize(collection_hash:, cocina_object:, skip_roundtrip: false)
    @collection_hash = collection_hash
    @cocina_object = cocina_object
    @skip_roundtrip = skip_roundtrip
  end

  def call
    ::Collection.transaction do
      if !skip_roundtrip && !CollectionRoundtripper.call(collection_form:, cocina_object:)
        raise ImportError, "Collection #{druid} cannot be roundtripped"
      end

      add_project_tags
      collection
    end
  end

  private

  attr_reader :collection_hash, :cocina_object, :skip_roundtrip

  def collection # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @collection ||= ::Collection.find_or_create_by!(druid:) do |collection|
      collection.user = UserImporter.call(user_json: collection_hash['creator'])
      collection.title = Cocina::Parser.title_for(cocina_object:)
      collection.object_updated_at = cocina_object.modified
      collection.release_option = release_option
      collection.release_duration = collection_hash['release_duration']
      collection.access = option_for(collection_hash['access'])
      collection.doi_option = option_for(collection_hash['doi_option'])
      collection.license_option = option_for(collection_hash['license_option'])
      collection.license = license
      collection.custom_rights_statement_option = custom_rights_statement_option
      collection.provided_custom_rights_statement = collection_hash['provided_custom_rights_statement']
      collection.custom_rights_statement_instructions = custom_rights_statement_instructions
      collection.email_when_participants_changed = collection_hash['email_when_participants_changed']
      collection.email_depositors_status_changed = collection_hash['email_depositors_status_changed']
      collection.review_enabled = collection_hash['review_enabled']
      collection.depositors = users_from('depositors')
      collection.reviewers = users_from('reviewed_by')
      collection.managers = users_from('managed_by')
      collection.created_at = collection_hash['created_at']
    end
  end

  def collection_form
    @collection_form ||= Form::CollectionMapper.call(cocina_object:, collection:)
  end

  def option_for(option)
    return 'depositor_selects' if option == 'depositor-selects'

    option
  end

  def release_option
    # There are a small number of H2 collections that have a delay release option.
    # This is being removed in H3, so they are being mapped to depositor_selects.
    return 'immediate' if collection_hash['release_option'] == 'immediate'

    'depositor_selects'
  end

  def license
    if collection_hash['license_option'] == 'required'
      collection_hash['required_license']
    else
      collection_hash['default_license']
    end
  end

  def custom_rights_statement_option
    if collection_hash['allow_custom_rights_statement'] == false
      'no'
    elsif collection_hash['provided_custom_rights_statement'].present?
      'provided'
    else
      'depositor_selects'
    end
  end

  # This field was renamed via migration; we want to populate it with a default
  # if left empty in H2 and the collection is set to 'depositor selects'
  def custom_rights_statement_instructions
    return unless custom_rights_statement_option == 'depositor_selects'

    collection_hash['custom_rights_statement_custom_instructions'].presence ||
      I18n.t('terms_of_use.default_use_statement_instructions')
  end

  def users_from(field)
    collection_hash[field].map { |user_json| UserImporter.call(user_json:) }
  end

  def druid
    collection_hash['druid']
  end

  def add_project_tags
    Dor::Services::Client.object(druid).administrative_tags.create(tags: ['Project : H3'])
  end
end
