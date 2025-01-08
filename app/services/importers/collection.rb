# frozen_string_literal: true

module Importers
  # Imports a collection from a JSON export from H2.
  class Collection
    def self.call(...)
      new(...).call
    end

    def initialize(collection_json:)
      @collection_json = collection_json
    end

    def call
      ::Collection.transaction do
        unless ToCollectionForm::RoundtripValidator.roundtrippable?(
          collection_form:, cocina_object:
        )
          raise Error,
                "Collection #{druid} cannot be roundtripped"
        end

        collection
      end
    end

    private

    attr_reader :collection_json

    def collection # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @collection ||= ::Collection.find_or_create_by!(druid:) do |collection|
        collection.user = User.call(user_json: collection_json['creator'])
        collection.title = CocinaSupport.title_for(cocina_object:)
        collection.object_updated_at = cocina_object.modified
        collection.release_option = release_option
        collection.release_duration = collection_json['release_duration']
        collection.access = option_for(collection_json['access'])
        collection.doi_option = option_for(collection_json['doi_option'])
        collection.license_option = option_for(collection_json['license_option'])
        collection.license = license
        collection.custom_rights_statement_option = custom_rights_statement_option
        collection.provided_custom_rights_statement = collection_json['provided_custom_rights_statement']
        collection.custom_rights_statement_custom_instructions = collection_json['custom_rights_statement_custom_instructions'] # rubocop:disable Layout/LineLength
        collection.email_when_participants_changed = collection_json['email_when_participants_changed']
        collection.email_depositors_status_changed = collection_json['email_depositors_status_changed']
        collection.review_enabled = collection_json['review_enabled']
        collection.depositors = users_from('depositors')
        collection.reviewers = users_from('reviewed_by')
        collection.managers = users_from('managed_by')
      end
    end

    def cocina_object
      @cocina_object ||= Sdr::Repository.find(druid:)
    end

    def collection_form
      @collection_form ||= ToCollectionForm::Mapper.call(cocina_object:, collection:)
    end

    def option_for(option)
      return 'depositor_selects' if option == 'depositor-selects'

      option
    end

    def release_option
      # There are a small number of H2 collections that have a delay release option.
      # This is being removed in H3, so they are being mapped to depositor_selects.
      return 'immediate' if collection_json['release_option'] == 'immediate'

      'depositor_selects'
    end

    def license
      if collection_json['license_option'] == 'required'
        collection_json['required_license']
      else
        collection_json['default_license']
      end
    end

    def custom_rights_statement_option
      if collection_json['allow_custom_rights_statement'] == false
        'no'
      elsif collection_json['provided_custom_rights_statement'].present?
        'provided'
      else
        'depositor_selects'
      end
    end

    def users_from(field)
      collection_json[field].map { |user_json| User.call(user_json:) }
    end

    def druid
      collection_json['druid']
    end
  end
end
