# frozen_string_literal: true

module ToCollectionForm
  # Maps Cocina Collection to CollectionForm
  class Mapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
      @collection = Collection.find_by(druid: cocina_object.externalIdentifier)
    end

    def call
      CollectionForm.new(params)
    end

    private

    attr_reader :cocina_object, :collection

    def params
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: CocinaSupport.title_for(cocina_object:),
        description: CocinaSupport.abstract_for(cocina_object:), # Cocina abstract maps to Collection description
        contact_emails_attributes: CocinaSupport.contact_emails_for(cocina_object:),
        related_links_attributes: CocinaSupport.related_links_for(cocina_object:),
        managers_attributes:,
        depositors_attributes:,
        version: cocina_object.version
      }
    end

    def managers_attributes
      return [] if collection&.managers.blank?

      collection.managers.map do |manager|
        { sunetid: manager.email_address.delete_suffix('@stanford.edu') }
      end
    end

    def depositors_attributes
      return [] if collection&.depositors.blank?

      collection.depositors.map do |depositor|
        { sunetid: depositor.email_address.delete_suffix('@stanford.edu') }
      end
    end
  end
end
