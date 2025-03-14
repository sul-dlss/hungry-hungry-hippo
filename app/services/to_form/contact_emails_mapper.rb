# frozen_string_literal: true

module ToForm
  # Maps the value from the accessContact field in the Cocina::DescriptiveAccessMetadata object.
  # to the email value for a contact_email in the WorkForm
  class ContactEmailsMapper < BaseMapper
    def initialize(cocina_object:, works_contact_email: nil)
      @cocina_object = cocina_object
      @works_contact_email = works_contact_email
      super(cocina_object:)
    end

    # @return [Array<Hash>, Nil] with keys for email
    def call
      return nil if cocina_object.description.access.blank?

      cocina_object.description.access.accessContact.filter_map do |access_contact|
        next if access_contact.value.blank? || access_contact.value == works_contact_email

        { 'email' => access_contact.value }
      end.presence
    end

    private

    attr_reader :works_contact_email
  end
end
