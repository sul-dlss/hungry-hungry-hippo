# frozen_string_literal: true

module ToCollectionForm
  # Maps Cocina Collection to CollectionForm
  class Mapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, collection:)
      @cocina_object = cocina_object
      @collection = collection
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
        title: cocina_description.title,
        description: CocinaSupport.abstract_for(cocina_object:), # Cocina abstract maps to Collection description
        contact_emails_attributes:,
        related_links_attributes: CocinaSupport.related_links_for(cocina_object:),
        managers_attributes: participant_attributes(:managers),
        depositors_attributes: participant_attributes(:depositors),
        version: cocina_object.version
      }
    end

    # @param [Symbol] role :managers or :depositors
    # @return [Array<Hash>] an array of participant attributes
    # Creates the attribute hash of sunetids for the given role to be used in the CollectionForm
    def participant_attributes(role)
      collection.send(role).map do |participant|
        { sunetid: participant.sunetid }
      end
    end

    def contact_emails_attributes
      cocina_description.contact_emails.map { |email| { email: } }
    end

    def cocina_description
      @cocina_description ||= CocinaParsers::Description.new(cocina_object:)
    end
  end
end
